*A user-friendly app for precise tracking of medication information, ensuring correct adherence and preventing mistakes.*

## Table of Contents
- [About](#about)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## About
MedBox Genie helps users stay on top of their prescribed medication by providing features like medication tracking, automated reminders, low stock notifications, expiry notifications, and survey feedback to monitor side effects. It aims to help users adhere to their medication schedules while maintaining a secure and organized record.

## Features
- *Enter New Medication*: Users can add their medication details, including dosage, frequency, and duration.
- *Automated Reminders*: Get notified about your medication at the exact times set by the user to ensure adherence.
- *Low Medication Stock Alerts*: Receive alerts when the stock of a medication drops below the critical threshold (e.g., three pills remaining).
- *Expiry Notifications*: Stay informed about upcoming medication expirations to avoid taking expired medication.
- *Track Symptoms and Side Effects*: Regular surveys to track how the medication is affecting the user.

## Technology Stack
- *Frontend*: Swift (iOS), SwiftUI
- *Backend*: Firebase Firestore (for data storage)
- *Notifications*: UNUserNotificationCenter (for local notifications)

## Installation
To run MedBox Genie locally, follow these steps:

1. Clone the repository:
   sh
   git clone https://github.com/username/medbox-genie.git
   
2. Open the project in Xcode:
   sh
   cd medbox-genie
   open MedBoxGenie.xcodeproj
   
3. Make sure you have an active Firebase account and configure the Firebase settings within the project.
4. Run the app on the simulator or a physical device.

## Usage
1. *Add New Medication: Navigate to the **Add Medication* screen using the "+" button. Enter the medication name, frequency, start time, duration, and total pills.
2. *Receive Reminders*: The app will notify you based on your prescribed medication schedule.
3. *Manage Stock*: The app alerts you when your medication count reaches a low threshold.
4. *Monitor Expiry*: Stay informed about upcoming medication expirations.
5. *Track Side Effects*: Fill out surveys related to your symptoms and side effects for improved tracking.

## Screenshots
(Add screenshots of your application here, highlighting important screens like Medication List, Add Medication, Notifications, etc.)

## Contributing
We welcome contributions! To contribute:
1. Fork the repository.
2. Create your feature branch (git checkout -b feature/AmazingFeature).
3. Commit your changes (git commit -m 'Add some AmazingFeature').
4. Push to the branch (git push origin feature/AmazingFeature).
5. Open a pull request.

## License
Distributed under the MIT License. See LICENSE for more information.

## Contact
*Project Maintainers*:  
- Irem Naz Celen  
- Beemnet Andualem Belete  
- Anyuan Li

For questions or suggestions, feel free to reach out to us via GitHub or create an issue in the repository.
