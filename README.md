# mule-rpi

Scripts for installing and configuring Mule runtime on a Raspberry Pi model 3/3B/3B+. Do not use on older models of the Raspberry Pi.

### Usage
If your Raspberry Pi has an active internet connection, you can download and run these scripts directly from the Rpi.

**Installing Mule 3 CE (Community Edition)**
```
wget -O - https://raw.githubusercontent.com/rajprins/mule-rpi/master/install-mule3CE.sh | bash
```

**Installing Mule 3 EE (Enterprise Edition)**
```
wget -O - https://raw.githubusercontent.com/rajprins/mule-rpi/master/install-mule3EE.sh | bash
```

**Installing Mule 4 CE (Community Edition)**
```
wget -O - https://raw.githubusercontent.com/rajprins/mule-rpi/master/install-mule4CE.sh | bash
```

**Installing Mule 4 EE (Enterprise Edition)**
```
wget -O - https://raw.githubusercontent.com/rajprins/mule-rpi/master/install-mule4EE.sh | bash
```

Note that the Enterprise Editions of the Mule runtime require a license. Without a license, the EE runtime behaves as a 30-day trial.