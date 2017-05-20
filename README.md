# Amble

[![Build Status](https://travis-ci.org/jonomuller/Amble.svg?branch=master)](https://travis-ci.org/jonomuller/Amble)

A social walking app for iOS written in Swift. Created for my final year project at Imperial College London.

## Current Features

- Login and create an account
- Track walks and record information about the time, distance and number of steps
- Save walks and view them on your profile
- Earn achievements by tracking walks and generating daily streaks, which count towards your total score
- Invite other users to go on a walk

## Requirements

- Xcode 8.3
- Swift 3
- [Cocoapods](https://cocoapods.org)

## Installation

Clone this repository and run `pod install` to install the dependencies for the project.

## Dependencies

- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - easy parsing of JSON from API
- [Alamofire](https://github.com/Alamofire/Alamofire) - networking library to communicate with API
- [Locksmith](https://github.com/matthewpalmer/Locksmith) - simple keychain access to store user's credentials
- [Chameleon](https://github.com/ViccAlexander/Chameleon) - a flat colour framework
- [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView) - custom loading animations

### Testing dependencies

- [Mockingjay](https://github.com/kylef/Mockingjay) - stubs HTTP requests when testing API communication
- [Quick](https://github.com/Quick/Quick) - testing framework for behaviour-driven development
- [Nimble](https://github.com/Quick/Nimble) - a nice matcher framework
