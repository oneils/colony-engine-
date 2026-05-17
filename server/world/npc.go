package world

import "math/rand/v2"

// NPC represents a single non-player character in the colony simulation.
type NPC struct {
	ID       int      `json:"id"`
	Size     int      `json:"size"`
	Position Position `json:"position"`
}

// NewNPC creates a new NPC with zero values.
func NewNPC() NPC {
	return NPC{}
}

// Position holds the 2D coordinates of an NPC on the game grid.
type Position struct {
	X int `json:"x"`
	Y int `json:"y"`
}

// StateResponse is the JSON payload returned by the /npcs/state endpoint.
type StateResponse struct {
	NPCS []NPC `json:"npcs"`
}

var initialState = []NPC{
	{ID: 1, Size: 15, Position: Position{X: 0, Y: 50}},
	{ID: 2, Size: 15, Position: Position{X: 0, Y: 150}},
	{ID: 3, Size: 15, Position: Position{X: 0, Y: 250}},
}

// FetchState returns a snapshot of the current NPC positions and advances
// each NPC by a random step: X always moves right, Y drifts up or down.
func FetchState() StateResponse {
	snapShot := make([]NPC, len(initialState))
	copy(snapShot, initialState)

	for i := range initialState {
		initialState[i].Position.X += rand.IntN(20) + 10
		initialState[i].Position.Y += rand.IntN(61) - 30
	}
	return StateResponse{NPCS: snapShot}
}
