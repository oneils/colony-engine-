package world

import "math/rand/v2"

type NPC struct {
	ID       int      `json:"id"`
	Size     int      `json:"size"`
	Position Position `json:"position"`
}

func NewNPC() NPC {
	return NPC{}
}

type Position struct {
	X int `json:"x"`
	Y int `json:"y"`
}

type StateResponse struct {
	NPCS []NPC `json:"npcs"`
}

var initialState = []NPC{
	{ID: 1, Size: 15, Position: Position{X: 0, Y: 50}},
	{ID: 2, Size: 15, Position: Position{X: 0, Y: 150}},
	{ID: 3, Size: 15, Position: Position{X: 0, Y: 250}},
}

func FetchState() StateResponse {
	snapShot := make([]NPC, len(initialState))
	copy(snapShot, initialState)

	for i := range initialState {
		initialState[i].Position.X += rand.IntN(20) + 10
		initialState[i].Position.Y += rand.IntN(61) - 30
	}
	return StateResponse{NPCS: snapShot}
}
