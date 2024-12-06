*A user-friendly app for precise tracking of medication information, ensuring correct adherence and preventing mistakes.*

## Table of Contents
- [About](#about)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
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
   git clone [https://github.com/irem-naz/medbox-genie.git](https://github.com/irem-naz/MedBox-Genie.git)
   
2. Open the project in Xcode:
   sh
   cd medbox-genie
   open MedBoxGenie.xcodeproj
3. Press the run button on Xcode and run the app on the simulator or a physical device.

## Usage
1. *Add New Medication*: Navigate to the **Add Medication* screen using the "+" button. Enter the medication name, frequency, start/end time, duration, dosage, quantity expiry date, and select the time(hour/minute) you would like to take the medicine, click "save" and the system will display your medication details on the main page.
2. *Receive Reminders*: The app will notify you based on your inputted medicine information, you will receive a banner with sound notifying you to take medicine, it also notifies you of the number of pills you have left in the inventory.
3. *Manage Stock*: The app alerts you when your medication count reaches 3, it will be sent after a short delay reminding you to stock up on medicine.
4. *Monitor Expiry*: Stay informed about upcoming medication expirations, based on the expiry date you provided the app will notify you when that day arrives.
5. *Track Side Effects*: Fill out surveys related to your symptoms and side effects for improved tracking, it will be sent after you take the medicine, enabling you to track any possible side effects that you are feeling.


## Testing
The testing is done through Xcode testing suite. The tests are inside the *testing-branch* for non-notification related parts of the code while all of the notification related tests are inside the *testing-notifications* branch. They bith can be accessed through the branches in this repo. In order to get the coverage report, ope the files inside the Xcode IDE with the Simulator and Testing Suite set-up. The tests can be run by going to the Test navigator, and pressing the run button. The coverage report will be listed at the Report navigator with the necessary information on each test's pass as well as the overall coverage report. 

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
