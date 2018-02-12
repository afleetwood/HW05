defmodule Memory.Game do
  # Start a new game
  def new do
    restartGame()
  end

  # Reset the state to a blank, unstarted game
  def restartGame do
    %{
      tiles: makeTiles(),
      score: 0,
      oneFlipped: false,
      guessTile1: nil,
      guessTile2: nil,
      wait: false,
    }
  end

  # Create and shuffle the 4x4 grid of tiles
  def makeTiles() do
    values = Enum.shuffle(["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F", "G", "G", "H", "H"])
    tiles = Stream.with_index(values, 1)
      |> Enum.map(fn {letter, index} ->
        %{
	  :value => letter,
	  :status => "hidden",
	  :key => index
	}
      end)
      tiles = tiles 
	|> Enum.chunk(1)
	|> Map.new(fn tile ->
	  {elem(Map.fetch(Enum.at(tile, 0), :key), 1), Enum.at(tile, 0)} end)

      tiles
  end
  
  # Define the state that the client sees
  def clientView(game) do
    %{
      tiles: Map.values(game.tiles),
      score: game.score,
      wait: game.wait,
    }
  end

  # Take action when a tile is clicked
  def clickTile(game, key) do
    guessTile1 = game.guessTile1
    oneFlipped = game.oneFlipped
    tile = game.tiles[key]
    
    # Determine whether a new tile was clicked
    game = if oneFlipped do
      if tile.key === guessTile1.key do
        # The clicked tile is still flipped from before
	game
      else
	# The clicked tile is a new guess
	if tile.value === guessTile1.value do
	  # The tile values match
          tile1 = %{
	    :value => tile.value,
	    :status => "matched",
	    :key => tile.key
	  }
	  tile2 = %{
	    :value => tile.value,
	    :status => "matched",
	    :key => tile.key
	  }
          newGame = game
	    |> Map.put(:oneFlipped, false)
	    |> Map.put(:guessTile1, nil)

	  newTiles = game.tiles
	    |> Map.put(tile.key, tile1)
	    |> Map.put(guessTile1.key, tile2)

          Map.put(newGame, :tiles, newTiles)
	  else
	    # The tile values do not match
	    flippedTile = %{
	      :value => tile.value,
	      :status => "flipped",
	      :key => tile.key
	    }
	    Map.put(game, :oneFlipped, false)
	    Map.put(game, :guessTile1, nil)
	    Map.put(game.tiles, tile.key, flippedTile)
	    
	    newGame = game
	      |> Map.put(:oneFlipped, false)
	      |> Map.put(:guessTile1, tile)
	      |> Map.put(:guessTile2, guessTile1)
	      |> Map.put(:wait, true)

	    newTiles = game.tiles
	      |> Map.put(tile.key, flippedTile)

	    Map.put(newGame, :tiles, newTiles)
	  end
        end
      else
	flippedTile = %{
	  :value => tile.value,
	  :status => "flipped",
	  :key => tile.key
	}

	game
	  |> Map.put(:oneFlipped, true)
	  |> Map.put(:guessTile1, tile)
	  |> Map.put(:tiles, Map.put(game.tiles, tile.key, flippedTile))
      end

      newScore = game.score + 1
      Map.put(game, :score, newScore)
  end

  def undo_guesses(game) do
    tile1 = game.guessTile1
    tile2 = game.guessTile2

    hideTile1 = %{
      :value => tile1.value,
      :status => "hidden",
      :key => tile1.key
    }
    hideTile2 = %{
      :value => tile2.value,
      :status => "hidden",
      :key => tile2.key
    }

    newTiles = Map.put(game.tiles, tile1.key, hideTile1)
      |> Map.put(game.tiles, tile2.key, hideTile2)

    Map.put(game, :tiles, newTiles)
      |> Map.put(:wait, false)
  end
end
