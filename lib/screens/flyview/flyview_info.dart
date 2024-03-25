import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:peachgs_flutter/provider/multivehicle.dart';

class FlyViewInfo extends StatefulWidget {
  const FlyViewInfo({
    required this.moveto,
    super.key
  });

  final Function(LatLng loc) moveto;

  @override
  State<FlyViewInfo> createState() => _FlyViewInfoState();
}

class _FlyViewInfoState extends State<FlyViewInfo> {
  // 유효한 위경도 좌표인지 검사
  bool _isValidLocation(LatLng loc) {
    double lat = loc.latitude;
    double lng = loc.longitude;

    bool vaildLat = (lat.isFinite && (lat.abs() <= 90));
    bool validLng = (lng.isFinite && (lng.abs() <= 180));

    return (vaildLat && validLng);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(40)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 왼쪽 아이콘
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    var vehicle = MultiVehicle().activeVehicle();

                    if(vehicle == null) return;

                    LatLng loc = LatLng(vehicle.lat, vehicle.lon);
                    if(_isValidLocation(loc)) {
                      widget.moveto(loc);
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/image/Quad.svg',
                    width: 50,
                    height: 50,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  )
                ),
                const Padding(padding: EdgeInsets.only(bottom: 5)),
                Selector<MultiVehicle, int?>(
                  selector: (context, multivehicle) => multivehicle.activeVehicle()?.id,
                  builder: (context, id, _) {
                    return Text(
                      (id != null) ? '기체 $id번' : '연결 대기 중',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                    );
                  },
                )
              ],
            ),
            // 오른쪽 정보
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width / 150,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 3,
                  children: [
                    Selector<MultiVehicle, double?>(
                      selector: (context, multivehicle) => multivehicle.activeVehicle()?.alt,
                      builder: (context, alt, _) {
                        return Text(
                          (alt != null) ? 'Alt : ${alt.toStringAsFixed(1)}m' : 'Alt : 0.0m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold
                          )
                        );
                      },
                    ),
                    Selector<MultiVehicle, int?>(
                      selector: (context, multivehicle) => multivehicle.activeVehicle()?.gpsSat,
                      builder: (context, sat, _) {
                        return Text(
                          (sat != null) ? 'Sat : $sat' : 'Sat : 0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold
                          )
                        );
                      },
                    ),
                    Selector<MultiVehicle, double?>(
                      selector: (context, multivehicle) => multivehicle.activeVehicle()?.hSpeed,
                      builder: (context, groundSpeed, _) {
                        return Text(
                          (groundSpeed != null) ? 'H.S : ${groundSpeed.toStringAsFixed(1)}m/s' : 'H.S : 0m/s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold
                          )
                        );
                      },
                    ),
                    Selector<MultiVehicle, double?>(
                      selector: (context, multivehicle) => multivehicle.activeVehicle()?.vSpeed,
                      builder: (context, verticalSpeed, _) {
                        return Text(
                          (verticalSpeed != null) ? 'V.S : ${verticalSpeed.toStringAsFixed(1)}m/s' : 'V.S : 0m/s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold
                          ),
                        );
                      },
                    ),
                    Selector<MultiVehicle, double?>(
                      selector: (context, multivehicle) => multivehicle.activeVehicle()?.hdop,
                      builder: (context, hdop, _) {
                        return Text(
                          (hdop != null) ? 'HDOP : $hdop' : 'HDOP : 0.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold
                          ),
                        );
                      },
                    ),
                    Selector<MultiVehicle, double?>(
                      selector: (context, multivehicle) => multivehicle.activeVehicle()?.vdop,
                      builder: (context, vdop, _) {
                        return Text(
                          (vdop != null) ? 'VDOP : $vdop' : 'VDOP : 0.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold
                          ),
                        );
                      },
                    )
                  ],
                )
              )
            )
          ],
        )
      )
    );
  }
}