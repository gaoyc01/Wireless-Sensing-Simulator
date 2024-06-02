# Wireless-Sensing-Simulator
The Wireless Sensing Simulator is a CSI simulator developed by the MobiSense group at Tsinghua University. It is developed with Matlab for researchers to cost-effectively and quickly create CSI datasets for testing. 

Wireless Sensing Simulator can simulate the CSI data of any protocol under the 802.11 protocol family, and it can even simulate the CSI data of a cellular network with freely set variables such as bandwidth, center frequency, number of subcarriers, number of antennas, and so on. In Wireless Sensing Simulator, we can use our own modeled 3D scene to complete the simulation, where the location, orientation, and number of access points (APs) and Internet of Things (IoT) devices are modifiable. The simulation is realized based on the ray tracing model, and the real geometrical information (e.g., AoA, AoD, and ToF) of all multipath signals between AP and IoT devices will be available. We integrate the traditional AoA, ToF, and Doppler spectrum estimation algorithms, which will be described in detail in the CSI Feature Extraction chapter of [Wireless Sensing Tutorial](http://tns.thss.tsinghua.edu.cn/wst/docs/welcome)[<sup>1]().

We have verified the effectiveness of this tool in [Wi-Prox](https://ieeexplore.ieee.org/document/10437884)[<sup>2](). Furthermore, Wireless Sensing Simulator is open source, and all functionalities are implemented in software. Therefore, one can extend the functionalities of Wireless Sensing Simulator with their own codes under the GPL license.



> [<sup>1]() http://tns.thss.tsinghua.edu.cn/wst/docs/welcome
> 
> [<sup>2]() Gao Y, Chi G, Zhang G, et al. Wi-Prox: Proximity Estimation of Non-Directly Connected Devices via Sim2Real Transfer Learning[C]//GLOBECOM 2023-2023 IEEE Global Communications Conference. IEEE, 2023: 5629-5634.

<div style="text-align: center; display: flex; justify-content: space-between;">
  <img src="/Fig/interface.png" style="width: 48%;">
  <img src="/Fig/raytracing.jpg" style="width: 42%;">
</div>
