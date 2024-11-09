//
//  Guide.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

struct Guide: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    
    static let guides = [
        
        Guide(title: "Quick Panel", content: """
        _This feature is only available on macOS_

        The app features a Spotlight-like floating panel for interacting with LLMs. To configure:

        - Navigate to **Settings > Quick Panel** to set a keyboard shortcut.
        - Once enabled, using the shortcut will activate a hovering panel for LLM interaction.
        - Additional settings, such as the Quick Panel's separate default provider and model, can also be configured in the same section.
        """),
        
        Guide(title: "Plugins", content: """
        Extend the capabilities of Language Learning Models (LLMs) with these powerful plugins:

        1. **URLScrape Plugin**
           - Scrapes content from URLs to provide additional context.

        2. **Google Search Plugin**
           - Performs live Google searches for up-to-date information.
           - Pairs effectively with URLScrape for comprehensive data retrieval.

        3. **Image Generation Plugin**
           - Generates images from text inputs.

        4. **Transcribe Plugin**
           - Converts audio files into text.

        > Make sure the plugins are enabled in **Settings > Plugins** in order to use them. They are not enabled by default
        """),
        
        Guide(title: "Google Search Plugin", content: """
        ### How to Create a Programmable Search Engine

        1. Go to [Programmable Search Engine](https://programmablesearchengine.google.com/controlpanel/create) (Be sure you’re logged into Google)
        2. Name your search engine (e.g. ‘Google Image Search’)
        3. Choose "Search the entire web"
        4. Turn **ON** Image search
        5. Choose whether to turn SafeSearch **ON** or **OFF**
        6. Click "I’m not a robot"
        7. Click **Create**
        8. Click **Customize**
        9. Click **Copy** to copy your Search engine ID
        10. Paste your Search engine ID above

        ### How to Create a Google API Key

        1. Continuing from the previous step, scroll down. Beside "Custom Search JSON API" click **Get Started**
        2. Click **Get a Key**
        3. Click **Create a new project**, then click **Next**
        4. Give your project a name like “Image Search,” then click **Next**
        5. Click **Show Key**
        6. Copy your Google API Key above
        
        Finally, paste both credentials in **Settings > Plugin > Google Search**
        
        > Note that google programmable search only returns search result title and a small snippet and not the full content of the page. The URLScrape plugin may used to get the full content of the page.
        """),
        
        Guide(title: "URL Scrape Plugin", content: """
        > Note that the availability of the URLScrape plugin is subject to the availability of the Article Extractor2 API on RapidAPI.

        1. Go to the [Article Extractor2 API](https://rapidapi.com/pwshub-pwshub-default/api/article-extractor2) page on RapidAPI.
        2. Log in to your RapidAPI account. If you do not have an account, create one by clicking on **Sign Up**.
        3. After logging in, click on the **Subscribe** button to subscribe to the Article Extractor2 API service.
        4. Once you have subscribed (ideally the free tier is sufficient for most people), navigate to the **My Apps** section on RapidAPI.
        5. Select an existing app or create a new one for managing your API subscriptions.
        6. Copy the API key associated with your app.
        7. Open your GPTalks app and go to **Settings > Plugins > URLScrape**.
        8. Paste your RapidAPI API key into the appropriate field in the app settings.

        Ensure that you've completed each step before moving on to the next to successfully set up the API key and subscription.
        """),
        
        Guide(title: "Adding New Providers", content: """

        1. Navigate to **Settings > Providers**.
        2. Click the **Add** button to include any available providers.
        3. Enter the API key for your chosen provider on the provider page.
        > The app has a BYOK (Bring Your Own Key) model for all providers.
        4. Check the **Models** tab at the top of the provider page. Add new models or refresh the page to see if more models are available from the provider.
        """),
        
        Guide(title: "VertexAI Instructions", content: """
        The app currently only supports **Anthropic Claude** providers for **VertexAI**.

        ## Getting Started

        1. Make sure you have credits in Google Cloud with the models enabled.
        2. Check the quota and usage limits of individual models.
        3. Sign in to Google in the Vertex provider settings to use the VertexAI Service.

        _More providers are planned to be added later_
        """),
        
        Guide(title: "Adding Files", content: """
        ### File Support in the App

        This app offers native support for various file types, while others require specific provider models or may not be supported at all.  Here's a breakdown:

        * **Text Files:** Most text file content can be directly pasted and processed within the app.
        * **Image Files:** Image file support depends on the capabilities of the provider's model.
        * **Audio Files:** Audio files are transcribed using the transcription model set in **Settings > Plugins > Transcribe**.
        * **Google Gemini Models:** These models natively support a wider range of file types, including audio, video, and image files.
        * **Unsupported Files:**  You can still paste unsupported files, but the app or LLM might not recognize or process them correctly. If errors occur, try removing the file to restore normal app function.
        """),
    ]
}
