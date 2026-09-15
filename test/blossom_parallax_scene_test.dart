import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/blossom_parallax_scene.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/blossom_scene_tuning.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_breeze.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_tilt_tracker.dart';

void main() {
  group('TiltFusion', () {
    test('reads true roll from gravity, independent of pitch', () {
      const g = 9.81;
      const angle = 20 * math.pi / 180;
      // Right edge lowered by 20 degrees while leaning back 40 degrees.
      final fusion = TiltFusion()
        ..addAccelerometer(
          -g * math.sin(angle),
          g * math.cos(angle) * math.cos(0.7),
          g * math.cos(angle) * math.sin(0.7),
          0,
        );
      expect(fusion.roll, closeTo(angle, 1e-6));
      expect(fusion.pitch, closeTo(0.7, 1e-6));
    });

    test('gyroscope turns the estimate in the same direction as gravity', () {
      final fusion = TiltFusion()..addAccelerometer(0, 9.81, 0, 0);
      // Rolling clockwise (right edge down) is negative rotation about z.
      for (var i = 0; i < 50; i++) {
        fusion.addGyroscope(0, 0, -0.35, 0.02);
      }
      expect(fusion.roll, closeTo(0.35, 0.01));
    });

    test('accelerometer slowly corrects gyroscope drift', () {
      final fusion = TiltFusion()..addAccelerometer(0, 9.81, 0, 0);
      fusion.addGyroscope(0, 0, -0.5, 0.2);
      final drifted = fusion.roll;
      for (var i = 0; i < 300; i++) {
        fusion
          ..addGyroscope(0, 0, 0, 0.02)
          ..addAccelerometer(0, 9.81, 0, 0.02);
      }
      expect(drifted, greaterThan(0.05));
      expect(fusion.roll.abs(), lessThan(0.01));
    });
  });

  test('breeze stays within bounds and gusts arrive', () {
    final breeze = SceneBreeze(math.Random(1));
    var strongest = 0.0;
    for (var i = 0; i < 60 * 60; i++) {
      breeze.advance(1 / 60);
      for (final nx in const [0.0, 0.5, 1.0]) {
        final wind = breeze.at(nx);
        expect(wind, inInclusiveRange(0.0, 1.0));
        strongest = math.max(strongest, breeze.gustAt(nx));
      }
    }
    expect(strongest, greaterThan(BlossomSceneTuning.gustStrengthMin * 0.9));
  });

  test('simulation keeps motion within its safe limits', () {
    final simulation = BlossomSceneSimulation(random: math.Random(2));
    simulation.particles.configure(const Size(400, 800), const [
      Offset(120, 90),
      Offset(300, 40),
    ]);
    for (var i = 0; i < 60 * 90; i++) {
      // Violent, alternating tilt input.
      simulation.step(
        1 / 60,
        SceneMotion(
          tilt: Offset(i.isEven ? 5 : -5, 3),
          agitation: 1,
          lateralShake: i.isEven ? 1 : -1,
        ),
      );
      const swayBoost = 1 + BlossomSceneTuning.agitatedSwayLimitBoost;
      expect(simulation.tilt.dx.abs(), lessThanOrEqualTo(1.0));
      expect(
        simulation.treeSway.abs(),
        lessThanOrEqualTo(BlossomSceneTuning.treeSwayMax * swayBoost),
      );
      expect(
        simulation.frontBranchSway.abs(),
        lessThanOrEqualTo(BlossomSceneTuning.frontBranchSwayMax * swayBoost),
      );
    }
    for (final particle in simulation.particles.all) {
      expect(particle.x, inInclusiveRange(-80.0, 460.0));
      expect(particle.y, lessThan(800 + particle.size * 3 + 1));
    }
  });

  test('shaking sheds extra petals, which go dormant once calm', () {
    const size = Size(400, 800);
    final simulation = BlossomSceneSimulation(random: math.Random(3));
    simulation.particles.configure(size, const [Offset(120, 90)]);
    int falling() => simulation.particles.all
        .where((p) => p.opacityFor(size.height) > 0.01)
        .length;

    for (var i = 0; i < 60 * 4; i++) {
      simulation.step(1 / 60, const SceneMotion());
    }
    final calm = falling();
    expect(
      simulation.particles.all.where((p) => p.isBurst && !p.dormant),
      isEmpty,
    );

    for (var i = 0; i < 60 * 2; i++) {
      simulation.step(1 / 60, const SceneMotion(agitation: 1));
    }
    expect(falling(), greaterThan(calm + 10));

    // Shed petals finish their fall (far ones take close to a minute).
    for (var i = 0; i < 60 * 90; i++) {
      simulation.step(1 / 60, const SceneMotion());
    }
    expect(
      simulation.particles.all.where((p) => p.isBurst && !p.dormant),
      isEmpty,
    );
  });

  testWidgets('scene renders behind its child and stops cleanly', (
    tester,
  ) async {
    final boundary = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: const BlossomParallaxScene(
            enableMotionSensors: false,
            child: Center(child: Text('content')),
          ),
        ),
      ),
    );
    for (var i = 0; i < 90; i++) {
      await tester.pump(const Duration(milliseconds: 33));
    }
    expect(find.text('content'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Set BLOSSOM_SCENE_SNAPSHOT to a PNG path to look at a rendered frame.
    final snapshotPath = Platform.environment['BLOSSOM_SCENE_SNAPSHOT'];
    if (snapshotPath != null) {
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File(snapshotPath).writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }

    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
