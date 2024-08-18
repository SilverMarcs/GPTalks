extension Conversation {
    func toOpenAI() -> ChatQuery.ChatCompletionMessageParam {
        if self.imagePaths.isEmpty {
            return ChatQuery.ChatCompletionMessageParam(
                role: self.role.toOpenAIRole(),
                content: self.content
            )!
        } else {
            let visionContent: [ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent] = [
                .chatCompletionContentPartTextParam(.init(text: self.content))
            ] + self.imagePaths.map { imagePath in
                if let imageData = loadImageData(from: imagePath) {
                    return .chatCompletionContentPartImageParam(
                        .init(imageUrl: .init(
                            url: imageData,
                            detail: .auto
                        ))
                    )
                } else {
                    return .chatCompletionContentPartTextParam(.init(text: "Failed to load image. Notify the user."))
                }
            }
            
            return ChatQuery.ChatCompletionMessageParam(
                role: self.role.toOpenAIRole(),
                content: visionContent
            )!
        }
    }

    func toGoogle() -> ModelContent {
        // This supports sending a lot of data types
        
        if self.imagePaths.isEmpty {
            return ModelContent(
                role: role.toGoogleRole(),
                parts: [.text(content)]
            )
        } else {
            let visionContent: [ModelContent.Part] = self.imagePaths.map { imagePath in
                if let imageData = loadImageData(from: imagePath) {
                    return .jpeg(imageData)
                } else {
                    return .text("Failed to load image. Notify the user.")
                }
            } + [
                .text(content)
            ]
            
            return ModelContent(
                role: role.toGoogleRole(),
                parts: visionContent
            )
        }
    }
    
    func toClaude() -> MessageParameter.Message {
        // Initialize an array to hold ContentObject instances
        var contentObjects: [MessageParameter.Message.Content.ContentObject] = []
        
        // Add the text content
        contentObjects.append(.text(self.content))
        
        // Iterate over each image path, load the image, convert to base64, and append to contentObjects
        for imagePath in imagePaths {
            if let imageData = loadImageData(from: imagePath) {
                let base64String = imageData.base64EncodedString()
                let imageSource = MessageParameter.Message.Content.ImageSource(
                    type: .base64,
                    mediaType: .jpeg,
                    data: base64String
                )
                contentObjects.append(.image(imageSource))
            } else {
                print("Could not load image from path: \(imagePath)")
            }
        }
        
        // Create the visionContent with the collected contentObjects
        let visionContent: MessageParameter.Message = .init(
            role: self.role.toClaudeRole(),
            content: .list(contentObjects)
        )
        
        return visionContent
    }
    
}