# BLETroller 📱
### A TrollStore app for sending Apple Continuity and Proximity BLE advertisements

BLETroller lets you spoof and send Apple Proximity and Continuity BLE signals to other iDevices by using private CoreBluetooth frameworks. This is the protocol that people used on Flipper Zeros to crash iDevices running iOS versions earlier than 17.2 back in 2023.

---

<table align="center">
  <tr>
    <td align="center">
      <img src="https://github.com/shalamand3r/BLETroller/blob/main/BLETroller.png" width="300">
    </td>
    <td align="center">
      <img src="https://github.com/shalamand3r/BLETroller/blob/main/AppSSL.jpeg#gh-light-mode-only" width="625">
      <img src="https://github.com/shalamand3r/BLETroller/blob/main/AppSSD.jpeg#gh-dark-mode-only" width="625">
    </td>
  </tr>
</table>

---

## Usage

- **Different Payloads** → Includes payloads for ~~AirPods, Beats, AirTags,~~ Apple TV, and more.
- **Stealth Mode** → Hide your screen during active broadcasting. Exit by triple-tapping the screen.
- **BT Radar** → Shows detected BT devices nearby, so you have an idea of how many people you can annoy. Only partially supported on older hardware (such as iPhone 6s/7).

Download the latest version from **[Releases](https://github.com/shalamand3r/BLETroller/releases)**

---

###### Note: The bundle identifier for this app is com.apple.sharingd because iOS only allows some system processes to broadcast BLE advertisements (like when you reset your iDevice, it wil broadcast an advertisement prompting nearby devices to set it up). Idk what the consequences of installing an app w/ this bundle id will be, so use this @ your own risk!!!!

to do: ~~fix container access,~~ fix other payloads, add payloads for other OSes (?), make work on other ios versions??? publish source code LOL
