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
- **Stealth Mode** → Blacks out your screen during active broadcasting. Activate by holding the broadcast button; exit by triple-tapping the screen.
- **Console** → A console is included. It makes this app look cool. Useful for logging IDK. Now can show detected BT devices nearby so you have an idea of how many people you can annoy.

Download the latest version from **[Releases](https://github.com/shalamand3r/BLETroller/releases)**

---

###### Note: The bundle identifier for this app is com.apple.sharingd because iOS only allows some system processes to broadcast payloads that involve continuity. Idk what the consequences of installing an app w/ this bundle id will be, so use this @ your own risk!!!!

to do: ~~fix container access,~~ fix other payloads, add payloads for other OSes (?), make work on other ios versions??? publish source code LOL
