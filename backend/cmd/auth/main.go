package main

import "hydration-tracking/services/auth"

func main() {
	auth.InitDB()
	if err := auth.StartServer(); err != nil {
		panic(err)
	}
}
