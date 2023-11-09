import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

import 'package:gravity/app/router.dart';
import 'package:gravity/features/graph/bloc/graph_cubit.dart';
import 'package:gravity/domain/entity/edge_details.dart';
import 'package:gravity/domain/entity/node_details.dart';
import 'package:gravity/ui/utils/state_base.dart';

import 'graph_node_widget.dart';

class GraphBody extends StatelessWidget {
  const GraphBody({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<GraphCubit, GraphState>(
        buildWhen: (p, c) =>
            p.status != c.status || p.positiveOnly != c.positiveOnly,
        builder: (context, state) => switch (state.status) {
          FetchStatus.isEmpty || FetchStatus.isLoading => Container(),
          _ => GraphView<NodeDetails, EdgeDetails<NodeDetails>>(
              controller: context.read<GraphCubit>().graphController,
              maxScale: 3,
              minScale: 0.1,
              canvasSize: const GraphCanvasSize.fixed(Size(4000, 4000)),
              layoutAlgorithm: const FruchtermanReingoldAlgorithm(
                optimalDistance: 100,
                iterations: 1500,
                temperature: 500,
                showIterations: true,
              ),
              edgePainter: const _CustomEdgePainter(),
              labelBuilder: BottomLabelBuilder(
                labelSize: const Size(100, 20),
                builder: (context, node) => switch (node) {
                  final UserNode node => Text(
                      node.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  final BeaconNode node => Text(
                      node.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  _ => const Offstage(),
                },
              ),
              nodeBuilder: (context, node) => GraphNodeWidget(
                nodeDetails: node,
                onTap: () => context.read<GraphCubit>().setFocus(node),
                onDoubleTap: () => context.push(switch (node) {
                  final UserNode node => Uri(
                      path: pathProfileView,
                      queryParameters: {
                        'id': node.id,
                      },
                    ),
                  final BeaconNode node => Uri(
                      path: pathBeaconView,
                      queryParameters: {
                        'id': node.id,
                        'expanded': 'false',
                      },
                    ),
                  final CommentNode node => Uri(
                      path: pathBeaconView,
                      queryParameters: {
                        'id': node.beaconId,
                        'expanded': 'true',
                      },
                    ),
                }
                    .toString()),
              ),
            ),
        },
        listenWhen: (p, c) => c.hasError,
        listener: (context, state) {
          final error = state.error ?? 'Undescribed error';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ));
        },
      );
}

class _CustomEdgePainter
    implements EdgePainter<NodeDetails, EdgeDetails<NodeDetails>> {
  const _CustomEdgePainter();

  @override
  void paint(
    Canvas canvas,
    EdgeDetails edge,
    Offset sourcePosition,
    Offset destinationPosition,
  ) =>
      canvas.drawLine(
        sourcePosition,
        destinationPosition,
        Paint()
          ..color = edge.color
          ..strokeWidth = edge.strokeWidth,
      );
}
