# CurrencyCrafter

CurrencyCrafter is a robust iOS application for real-time currency conversion with offline support. Built using Swift and following clean architecture principles, it features:

## Key Features
- Real-time currency conversion using live exchange rates
- Offline caching support with CoreData
- Clean Architecture implementation
- Comprehensive test coverage
- Combine framework integration for reactive programming
- Modern SwiftUI interface

## Technical Highlights
- MVVM architecture pattern
- Repository pattern for data management
- CoreData for local persistence
- URLSession for networking
- Unit tests with XCTest
- Memory leak tracking
- Error handling and recovery

## Architecture
The app follows clean architecture principles with the following layers:
- **Presentation Layer**: Views and ViewModels
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Repositories and data sources

## Requirements
- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Installation
1. Clone the repository
```bash
git clone https://github.com/sajal4me/CurrencyCrafter.git
```
2. Open `CurrencyCrafter.xcodeproj` in Xcode
3. Build and run the project

## Testing
The project includes comprehensive unit tests. To run the tests:
1. Open the project in Xcode
2. Press `Cmd + U` or go to Product > Test

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Author
Sajal Gupta