# Google Tag Manager
Download your container-config json file from Tag Manager and add a resource-file node in your `config.xml`.

## Android
```
<platform name="android">
    <resource-file src="GTM-XXXXXXX.json" target="assets/containers/GTM-XXXXXXX.json" />
    ...
```

## iOS
```
<platform name="ios">
    <resource-file src="GTM-YYYYYYY.json" />
    ...
```
