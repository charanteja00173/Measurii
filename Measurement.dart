import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vec;
class  Measurement extends StatefulWidget {
  const Measurement({Key? key}) : super(key: key);

  @override
  _Measurement createState() => _Measurement();
}
class _Measurement extends State<Measurement> {
  late ARKitController arKitController;
  late ARKitPlane plane;
  late ARKitNode node;
  late vec.Vector3 lastPostion;
  late String anchorId;
  @override
  Widget build(BuildContext context) =>Scaffold(
    appBar: AppBar(title: const Text("Measurii"),),
    body: ARKitSceneView(showFeaturePoints: true,planeDetection: ARPlaneDetection.horizontal,onARKitViewCreated: onARViewCreated,enableTapRecognizer: true,),
  );
  void onARViewCreated(ARKitController arKitController){
    this.arKitController=arKitController;
    this.arKitController.onAddNodeForAnchor=addAnchor;
    this.arKitController.onARTap=(List<ARKitTestResult> ar){
      final planeTap=ar.firstWhere(
              (tap)=>tap.type== ARKitHitTestResultType.existingPlaneUsingExtent,);
      tapHandler(planeTap.worldTransform);
    };
  }
  void addAnchor(ARKitAnchor anchor){
    if(anchor is! ARKitPlaneAnchor){
      return;
  }
    addPlane(arKitController, anchor);
  }

  void addPlane(ARKitController arKitController,ARKitPlaneAnchor anchor) {
    anchorId =anchor.identifier;
    plane=ARKitPlane(
        width: anchor.extent.x,
        height: anchor.extent.z,
        materials:
        [
          ARKitMaterial(
              transparency: 0.5, diffuse: ARKitMaterialProperty(color: Colors.white,),
          ),
        ],
    );
    node=ARKitNode(geometry: plane,position: vec.Vector3(anchor.center.x,0,anchor.center.z),
      rotation: vec.Vector4(1,0,0,-math.pi/2),
    );
    arKitController.add(node,parentNodeName: anchor.nodeName);
  }

  void tapHandler(Matrix4 tranform){
  final position =vec.Vector3(tranform.getColumn(3).x,tranform.getColumn(3).y,tranform.getColumn(3).z,);
  final material=ARKitMaterial(
    lightingModelName: ARKitLightingModel.constant,diffuse: ARKitMaterialProperty(color: const Color.fromRGBO(253,153,83,1))
  );
  final sphere =ARKitSphere(
    radius: 0.003,materials: [material],
  );
  final node=ARKitNode(
    geometry: sphere,position: position,
  );
  arKitController.add(node);
  final line=ARKitLine(fromVector: lastPostion, toVector: position
  );
  final lineNode=ARKitNode(geometry: line);
  arKitController.add(lineNode);
  final distance=calDistance(position,lastPostion);
  final point=getMiddleVector(position,lastPostion);
  drawText(distance,point);
  }
String calDistance(vec.Vector3 A,vec.Vector3 B){
    final length=A.distanceTo(B);
    return '${(length*100).toStringAsFixed(2)} cm';
  }
  vec.Vector3 getMiddleVector(vec.Vector3 A,vec.Vector3 B){
    return vec.Vector3(
        (A.x+B.x)/2,
        (A.y+B.y)/2,
        (A.z+B.z)/2
    );
  }
  void drawText(String textDistance,vec.Vector3 point){
    final textGeometry =ARKitText(text: textDistance, extrusionDepth: 1,materials:
        [
          ARKitMaterial(diffuse: ARKitMaterialProperty(color: Colors.red),),],);
    const scale=0.001;
    final vectorScale=vec.Vector3(scale,scale,scale);
    final node=ARKitNode(
      geometry: textGeometry,
      position: point,
      scale: vectorScale,
    );
    arKitController.getNodeBoundingBox(node)
              .then((List<vec.Vector3> result){
      final minVector=result[0];
      final maxVector=result[1];
      final dx= (maxVector.x-minVector.x)/2*scale;
      final dy= (maxVector.y-minVector.y)/2*scale;
      final postion=vec.Vector3(
          node.position.x-dx,
          node.position.y-dy,
          node.position.z,
      );
      node.position=postion;
    });
    arKitController.add(node);
  }
}