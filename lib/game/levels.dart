import 'models.dart';

/// Six hand-verified levels.
///
/// Each one was authored constructively: a solved paddle layout was chosen
/// first, the flow was simulated, and tank colours plus capacities were read
/// off the recorded landings. A few paddles were then turned the wrong way —
/// that scrambled layout ships as the starting position and the list of
/// turns that undoes it ships as [LevelSpec.solution]. Solvability is a
/// property of the construction, not something checked after the fact.
const List<LevelSpec> kLevels = <LevelSpec>[
  LevelSpec(
    index: 1,
    name: 'PURE FLOW',
    difficulty: 'EASY',
    paddles: <PaddleSpec>[
      PaddleSpec(1, 4, PaddleDir.left),
      PaddleSpec(4, 1, PaddleDir.right),
      PaddleSpec(4, 2, PaddleDir.left),
      PaddleSpec(4, 3, PaddleDir.left),
    ],
    emitters: <EmitterSpec>[
      EmitterSpec(0, 3, DropColor.cyan),
      EmitterSpec(2, 3, DropColor.cyan),
      EmitterSpec(4, 3, DropColor.gold),
    ],
    tanks: <TankSpec>[
      TankSpec(DropColor.cyan, 3),
      TankSpec(DropColor.gold, 3),
      TankSpec(DropColor.cyan, 3),
    ],
    turnBudget: 6,
    solution: <int>[2],
  ),
  LevelSpec(
    index: 2,
    name: 'TWIN CURRENT',
    difficulty: 'EASY',
    paddles: <PaddleSpec>[
      PaddleSpec(2, 2, PaddleDir.right),
      PaddleSpec(2, 3, PaddleDir.left),
      PaddleSpec(3, 0, PaddleDir.left),
      PaddleSpec(3, 2, PaddleDir.right),
      PaddleSpec(4, 1, PaddleDir.left),
      PaddleSpec(4, 4, PaddleDir.right),
    ],
    emitters: <EmitterSpec>[
      EmitterSpec(0, 3, DropColor.cyan),
      EmitterSpec(2, 3, DropColor.gold),
      EmitterSpec(4, 3, DropColor.cyan),
    ],
    tanks: <TankSpec>[
      TankSpec(DropColor.cyan, 3),
      TankSpec(DropColor.gold, 3),
      TankSpec(DropColor.cyan, 3),
    ],
    turnBudget: 6,
    solution: <int>[0, 4],
  ),
  LevelSpec(
    index: 3,
    name: 'TRIPLE SPLIT',
    difficulty: 'MEDIUM',
    paddles: <PaddleSpec>[
      PaddleSpec(0, 1, PaddleDir.left),
      PaddleSpec(0, 2, PaddleDir.left),
      PaddleSpec(1, 3, PaddleDir.right),
      PaddleSpec(2, 1, PaddleDir.right),
      PaddleSpec(3, 4, PaddleDir.left),
      PaddleSpec(4, 1, PaddleDir.right),
      PaddleSpec(5, 4, PaddleDir.right),
    ],
    emitters: <EmitterSpec>[
      EmitterSpec(0, 2, DropColor.gold),
      EmitterSpec(1, 2, DropColor.cyan),
      EmitterSpec(3, 2, DropColor.cyan),
      EmitterSpec(4, 3, DropColor.violet),
    ],
    tanks: <TankSpec>[
      TankSpec(DropColor.gold, 2),
      TankSpec(DropColor.cyan, 4),
      TankSpec(DropColor.violet, 3),
    ],
    turnBudget: 5,
    solution: <int>[0, 2],
  ),
  LevelSpec(
    index: 4,
    name: 'CROSS TIDE',
    difficulty: 'MEDIUM',
    paddles: <PaddleSpec>[
      PaddleSpec(1, 3, PaddleDir.right),
      PaddleSpec(2, 1, PaddleDir.left),
      PaddleSpec(2, 2, PaddleDir.right),
      PaddleSpec(2, 3, PaddleDir.left),
      PaddleSpec(3, 1, PaddleDir.right),
      PaddleSpec(3, 3, PaddleDir.right),
      PaddleSpec(4, 1, PaddleDir.right),
      PaddleSpec(5, 1, PaddleDir.left),
      PaddleSpec(5, 3, PaddleDir.left),
    ],
    emitters: <EmitterSpec>[
      EmitterSpec(0, 3, DropColor.violet),
      EmitterSpec(1, 2, DropColor.gold),
      EmitterSpec(2, 2, DropColor.violet),
      EmitterSpec(4, 3, DropColor.cyan),
    ],
    tanks: <TankSpec>[
      TankSpec(DropColor.violet, 5),
      TankSpec(DropColor.gold, 2),
      TankSpec(DropColor.cyan, 3),
    ],
    turnBudget: 5,
    solution: <int>[1, 2, 4],
  ),
  LevelSpec(
    index: 5,
    name: 'DEEP CASCADE',
    difficulty: 'HARD',
    paddles: <PaddleSpec>[
      PaddleSpec(0, 3, PaddleDir.left),
      PaddleSpec(1, 0, PaddleDir.left),
      PaddleSpec(1, 1, PaddleDir.left),
      PaddleSpec(1, 2, PaddleDir.right),
      PaddleSpec(1, 4, PaddleDir.right),
      PaddleSpec(3, 1, PaddleDir.right),
      PaddleSpec(4, 0, PaddleDir.right),
      PaddleSpec(4, 1, PaddleDir.right),
      PaddleSpec(4, 3, PaddleDir.right),
      PaddleSpec(5, 4, PaddleDir.left),
    ],
    emitters: <EmitterSpec>[
      EmitterSpec(0, 2, DropColor.violet),
      EmitterSpec(1, 2, DropColor.violet),
      EmitterSpec(2, 2, DropColor.cyan),
      EmitterSpec(3, 2, DropColor.gold),
      EmitterSpec(4, 2, DropColor.gold),
    ],
    tanks: <TankSpec>[
      TankSpec(DropColor.violet, 4),
      TankSpec(DropColor.cyan, 2),
      TankSpec(DropColor.gold, 4),
    ],
    turnBudget: 4,
    solution: <int>[0, 3, 6],
  ),
  LevelSpec(
    index: 6,
    name: 'FINAL SURGE',
    difficulty: 'HARD',
    paddles: <PaddleSpec>[
      PaddleSpec(0, 2, PaddleDir.left),
      PaddleSpec(1, 2, PaddleDir.left),
      PaddleSpec(2, 3, PaddleDir.right),
      PaddleSpec(2, 4, PaddleDir.right),
      PaddleSpec(3, 0, PaddleDir.right),
      PaddleSpec(3, 1, PaddleDir.left),
      PaddleSpec(3, 2, PaddleDir.right),
      PaddleSpec(3, 4, PaddleDir.right),
      PaddleSpec(4, 0, PaddleDir.left),
      PaddleSpec(5, 0, PaddleDir.left),
      PaddleSpec(5, 3, PaddleDir.right),
      PaddleSpec(5, 4, PaddleDir.right),
    ],
    emitters: <EmitterSpec>[
      EmitterSpec(0, 2, DropColor.violet),
      EmitterSpec(1, 2, DropColor.gold),
      EmitterSpec(2, 3, DropColor.cyan),
      EmitterSpec(3, 2, DropColor.cyan),
      EmitterSpec(4, 2, DropColor.cyan),
    ],
    tanks: <TankSpec>[
      TankSpec(DropColor.violet, 2),
      TankSpec(DropColor.gold, 2),
      TankSpec(DropColor.cyan, 7),
    ],
    turnBudget: 4,
    solution: <int>[0, 4, 5, 11],
  ),
];

const int kMaxStars = 18;
