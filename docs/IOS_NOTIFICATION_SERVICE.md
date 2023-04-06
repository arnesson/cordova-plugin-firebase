# Step by Step Instructions to create a Notification Service Extension Provisioning Profile

In this tutorial we assume that you have already made the certificates to publish your app in the App Store.

## Step 1, create the `Notification Service Identifier`

 - Login to the [Apple Developer Program](https://developer.apple.com/account)
 - Click in **Certificates, Identifiers & Profiles** > **Identifiers**
 - Now click on + to add new identifier
 - Select `App IDs` and continue
 - Select type `App` and continue
 - For the `Description` write `AppName Notification Service` or whatever you want
 - For the `Bundle ID` write `app.package.name.NotificationService` an set in `Explicit`
 - In `Capabilities` leave those selected by default, it is possible that if your main package uses `Associated Domains` you have to activate it here
 - Click now in continue to save identifier

## Step 2, create the `Notification Service Profile`

 - Go now to **Profiles**
 - Now click on + to create new profile
 - Select `App Store` and continue
 - Select you `app.package.name.NotificationService` and continue
 - From the list, select the certificate you are currently using to sign your app for the App Store and continue
 - For the `Provisioning Profile Name` write `AppName Notification Service Profile` or whatever you want
 - Now click in Generate

## Step 3, configure Xcode

- First, download the new Profile with **Xcode** > **Preferences...** > **Accounts** > **Download Manual Profiles**
- In you xCode project, select **File** > **New** > **Target** and select `Notification Service Extension`
- For the `Product Name` write `NotificationService`
- Select in `Language` the `Swift`

## Step 4

- Replace the content of the created `NotificationService.swift` with the content of [NotificationService.swift](NotificationService.swift)

## Step 5

- Change the `provisioningProfile` from you `build.json` to an array with both profiles `{"app.package.name":"00000000-0000-0000-0000-000000000000", "app.package.name.NotificationService":"00000000-0000-0000-0000-000000000000"}`

Now you can send notifications with images using the following payload:

``` json
{
  "name": "my_notification",
  "notification": {
    "body": "Notification body",
    "title": "Notification title"
  },
  "data": {
    "notification_foreground": "true",
    "notification_ios_image_jpg": "https://...",
    "notification_ios_image_png": "https://...",
    "notification_ios_image_gif": "https://...",
  }
}
```