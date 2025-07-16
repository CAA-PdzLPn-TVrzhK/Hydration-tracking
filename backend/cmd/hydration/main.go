package main

import "hydration-tracking/services/hydration"

func main() {
	hydration.InitDB()
	if err := hydration.StartServer(); err != nil {
		panic(err)
	}
}
