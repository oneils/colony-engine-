package world

type GameCfg struct {
	Grid GridCfg `json:"grid"`
}

// GridCfg specifies the Grid Size in Cells:
// Width - how many cells horizontaly
// Height - how many cells vertically
type GridCfg struct {
	Width int `json:"width"`
	Hight int `json:"height"`
}
