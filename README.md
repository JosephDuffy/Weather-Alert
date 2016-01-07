#Weather Alert

Weather Alert is a basic iOS application for display weather and wind information. The data is provided pulled from the [OpenWeatherMap API](http://openweathermap.org/api).

## To Install

Weather Alert relies on Alamofire to perform HTTP requests. To install Alamofire run:

`carthage update --platform iOS`

An API key is required to run the application. An API key can be acquired from the [OpenWeatherMap website](http://openweathermap.org/appid). This API key should be placed in a plist file's `APIKey` property. This plist file must be called `Config.plist` and placed in the `Weather Alert` directory. An example file (`Config_example.plist`) file is provided for your convenience.