# Colony Engine — CS Learning Project

> **Project name:** Colony Engine  
> **Goal:** Learning Computer Science through practice — an NPC colony simulation as a live learning environment  
> **Stack:** Go (logic, server) + Godot 4 (visualization, client)  
> **Pace:** 5–8 hours per week

---

## Context and Motivation

The project combines three goals:

1. **CS fundamentals** following the [teachyourselfcs.com](https://teachyourselfcs.com/) curriculum — priority #1
2. **Technical interview prep** (LeetCode-style) — priority #2
3. **Godot knowledge and experience** for future game development — priority #3

**Core idea:** Godot is not a game — it's an interactive debugger. Algorithms and systems are visualized through NPC behavior. Beauty is not the goal — the goal is to see how the system works.

**Working principle:** getting shit done → understanding → going deeper. Working code first, theory on demand.

---

## System Architecture

```
┌─────────────────────┐         ┌─────────────────────┐
│     Godot 4         │  HTTP   │      Go server       │
│  (visualization)    │◄───────►│   (all logic)        │
│                     │  JSON   │                      │
│  - _draw() / MM2D   │         │  - NPC AI            │
│  - debug overlays   │         │  - algorithms        │
│  - click → info     │         │  - game loop         │
│  - polling /state   │         │  - data structures   │
└─────────────────────┘         └─────────────────────┘
```

**Godot does:** rendering points/lines/text, polling state, debug overlay on click  
**Go does:** all logic — NPCs, pathfinding, economy, queues, clusters  
**Boundary:** HTTP + JSON (later — protobuf/msgpack for Phase 3)

---

## NPC Visualization

| Phase | NPC Count | Rendering Method | Draw calls |
|-------|-----------|-----------------|------------|
| 0–1   | 50–100    | `_draw()` + `draw_circle()` | ~N |
| 2–3   | 500       | `_draw()` primitives | ~1 |
| 4–5   | 5000+     | `MultiMeshInstance2D` | 1 |

NPC color encodes state (phases 1–4) or cluster node membership (phase 5).

---

## Roadmap

### Phase 0 — Project Skeleton
**Status:** complete  
**Duration:** ~1 day (one focused session)  
**Tools:** Go `net/http`, Godot `HTTPRequest`, `_draw()`

**Result:** Go server returns `/state` JSON with NPC positions. Godot draws circles from coordinates. One NPC moves randomly on a grid. Two processes run separately and communicate over HTTP.

---

### Phase 1 — Algorithms & Data Structures
**Status:** not started  
**Duration:** 6 weeks  
**Tools:** Go (manual implementations), Godot (debug overlay), LeetCode

#### Week 1 — Array, Linked List, Stack, Queue
**Topic:** basic linear structures  
**Project:**
- `TaskQueue` based on a slice with Push/Pop — NPC task queue
- NPC inventory: fixed array of resources (wood, stone, food)
- Action history: stack of last 10 events
- Godot: click on NPC → overlay showing task queue

**LeetCode:** #232 Implement Queue using Stacks (Easy), #20 Valid Parentheses (Easy)  
**Theory:** Skiena ch. 3 — amortized complexity, when to use what  
**Result:** each NPC has an inventory and task queue visible in Godot

---

#### Week 2 — Hash Map, Hash Set
**Topic:** hashing, spatial partitioning  
**Project:**
- `ResourceMap: map[string]int` — global colony warehouse
- NPC lookup by ID: `map[int]*NPC` instead of linear search
- Spatial hash v1: divide map into 64×64 cells, `map[cellKey][]int`
- Godot: debug overlay — spatial hash cell borders

**LeetCode:** #1 Two Sum (Easy), #49 Group Anagrams (Medium)  
**Theory:** hash table internals — chaining vs open addressing, load factor, rehashing  
**Result:** NPC finds nearest resource via spatial hash, cells visible in Godot

---

#### Week 3 — Heap, Priority Queue
**Topic:** heap as a structure, prioritization  
**Project:**
- Replace `TaskQueue` with `PriorityQueue` (food > construction > patrol)
- Implement binary heap manually in Go (not `container/heap`)
- Global scheduler: assigns tasks to idle NPCs by priority
- Godot: NPC color reflects current task priority (red = urgent)

**LeetCode:** #215 Kth Largest Element (Medium), #347 Top K Frequent Elements (Medium)  
**Theory:** binary heap — insert O(log n), extract-min O(log n), heap vs sorted slice  
**Result:** NPCs pick tasks by priority, heap written manually and reused in A*

---

#### Week 4 — Graph, BFS, DFS
**Topic:** graph traversals  
**Project:**
- Map as a graph: cell = vertex, neighbors = edges with terrain weight
- BFS: find nearest resource of a given type
- DFS: check zone reachability (is an NPC trapped?)
- Godot: BFS frontier as an animated wave per frame

**LeetCode:** #200 Number of Islands (Medium), #133 Clone Graph (Medium)  
**Theory:** adjacency list vs matrix, BFS vs DFS — when to use which  
**Result:** NPC searches for resources via BFS, traversal wave visible in Godot

---

#### Week 5 — A* and Dijkstra
**Topic:** weighted shortest paths  
**Project:**
- A* in Go: open set = heap from week 3, closed set = hash from week 2
- Terrain costs: swamp = 5, forest = 2, road = 1
- Path caching: path only recalculated when target changes
- Godot: debug mode — visited cells + found path (like Phase 1 mockup)

**LeetCode:** #743 Network Delay Time / Dijkstra (Medium), #1514 Path with Max Probability (Hard)  
**Theory:** Dijkstra vs BFS, A* heuristic — Manhattan vs Euclidean  
**Result:** NPC moves via A*, terrain affects route, full debug view works live

> ⚠️ Heaviest week. A +1 week buffer is planned if needed.

---

#### Week 6 — Trees, Sorting, Topology
**Topic:** trees, sorting, dependencies  
**Project:**
- Dependency tree: production dependency tree (wood → planks → house)
- Topological sort: build order from the dependency graph
- Leaderboard: top-5 NPCs by productivity, updated incrementally
- Godot: panel with top NPCs and the construction dependency tree

**LeetCode:** #207 Course Schedule / topo sort (Medium), #56 Merge Intervals (Medium)  
**Theory:** BST vs hash, quicksort vs mergesort — O(n log n) and practical differences  
**Result:** colony knows the build order, Godot shows top NPCs

---

#### Phase 1 Summary
- 50 NPCs moving via A* with terrain, each with their own priority task queue
- Spatial hash cells visible in Godot — NPC searches for resources only in neighboring cells
- Dependency tree determines build order
- Debug mode: A* path / BFS wave / spatial hash — toggled by button in Godot
- ~12 LeetCode problems tied to implemented structures

---

### Phase 2 — Operating Systems
**Status:** not started  
**Duration:** ~4 weeks  
**Tools:** pure Go (Godot barely used)  
**Key topics:** goroutines as a scheduler, worker pool, syscalls, mini-shell  
**Core problem:** race condition when 2 NPCs take the same resource  
**Materials:** CS:APP ch. 8–12, Go runtime internals

---

### Phase 3 — Computer Networking
**Status:** not started  
**Duration:** ~4 weeks  
**Tools:** Go + Godot as client  
**Key topics:** TCP vs UDP, custom Godot↔Go protocol, serialization  
**Core problem:** Godot drops packets → NPCs freeze → reconnect needed  
**Materials:** Tanenbaum "Computer Networks", HTTP/1.1 RFC from scratch in Go

---

### Phase 4 — Databases
**Status:** not started  
**Duration:** ~4 weeks  
**Tools:** Go + SQLite/Postgres  
**Key topics:** event sourcing (every NPC action = a record), ACID transactions  
**Core problem:** save and restore state of 10,000 NPCs  
**Materials:** "Database Internals" (Petrov), CMU 15-445

---

### Phase 5 — Distributed Systems
**Status:** not started  
**Duration:** ~8 weeks  
**Tools:** Go cluster + Godot as cluster visualizer  
**Key topics:** Raft consensus, leader election, network partition, split brain  
**Godot role:** network simulator — click a node to kill it, add latency to a link  
**Core problem:** split brain — part of the colony freezes during partition  
**Materials:** DDIA (Kleppmann), MIT 6.824 labs (written in Go)

---

## Repository Structure (planned)

```
colony-engine/
├── server/           # Go — all logic
│   ├── main.go
│   ├── world/        # World, NPC, Game loop
│   ├── algorithms/   # A*, BFS, heap, spatial hash (written manually)
│   ├── economy/      # TaskQueue, ResourceMap, DependencyTree
│   └── api/          # HTTP handlers, JSON responses
├── client/           # Godot 4 project
│   ├── main.gd       # HTTPRequest polling, _draw()
│   ├── debug/        # Debug overlays — A* path, BFS wave, spatial hash
│   └── ui/           # Panels: NPC inventory, top list, cluster view
└── docs/README.md    # this file
```

---

## Conventions

- **Data structures** are implemented manually (not stdlib) — learning goal, not production
- **Godot contains no logic** — only rendering and forwarding input to Go
- **Debug mode** always accessible via button in Godot UI
- **LeetCode problems** are solved after implementing the corresponding structure in the project
- **One focus at a time** — don't move to the next week until the current result works

---

## Quick Start (Phase 0)

```bash
# Go server
cd server && go run main.go
# → http://localhost:8080/state

# Godot client
# Open client/ in Godot 4, run main.tscn scene
# NPC circle should move on the grid
```

---

*Last updated: Phase 0 — complete. Next step: Phase 1, Week 1 — Array, Linked List, Stack, Queue.*
