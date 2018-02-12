import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function run_memory(root) {
  ReactDOM.render(<Grid />, root);
}

function Tile(params) {
  var matched = params.status === "matched";
  var showing = params.status === "matched" || params.status === "flipped";

  if(matched) {
    return (
        <button className="match-tile">{params.value}</button>
    );
  }
  else {
    if (showing) {
      return (
          <button className="showing-tile" onClick={params.handleClick.bind(this)}>{params.value}</button>      
      );
    }
    else {
      return (
          <button className="hidden-tile" onClick={params.handleClick.bind(this)}></button> 
      );
    }
  }
}

class Grid extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
  
    this.state = {
      tiles: [],
      score: 0,
      wait: false,
    }

    this.channel.join()
	.receive("ok", receiveView.bind(this))
	.receive("error", output => { console.log("Unable to join channel", output) });
  }

  /* ----- GAME FUNCTIONS ----- */

  receiveView(view) {
    console.log("View received", view);
    if (view.game.wait) {
      setTimeout(function() {
	this.channel.push("undo_guesses").receive("ok", this.receiveView.bind(this), 1000);
      });
    }
    this.setState({
      tiles: view.game.tiles,
      score: view.game.score,
      wait: view.game.wait,
    });
  }

  handleClick(tile) {
    waiting = this.state.wait;

    if(!waiting) {
      this.channel.push("click", { tileKey: tile.key })
	.receive("ok", this.receiveView.bind(this));
    }
  }

  restartGame() {
    this.channel.push("restartGame").receive("ok", this.receiveView.bind(this));
  }

  /* ----- RENDERING FUNCTIONS ----- */

  renderTile(i) {
    var tiles = this.state.tiles.slice();
    return <Tile value={tiles[i].value} status={tiles[i].status} handleClick={this.handleClick.bind(this, i)} />;
  }

  render() {
    return (
      <div>
        <div className="game-message">"Memory Matching Game"</div>
        <div className="grid-row">
          {this.renderTile(0)}
          {this.renderTile(1)}
          {this.renderTile(2)}
          {this.renderTile(3)}
        </div>
        <div className="grid-row">
          {this.renderTile(4)}
          {this.renderTile(5)}
          {this.renderTile(6)}
          {this.renderTile(7)}
        </div>
        <div className="grid-row">
          {this.renderTile(8)}
          {this.renderTile(9)}
          {this.renderTile(10)}
          {this.renderTile(11)}
        </div>
        <div className="grid-row">
          {this.renderTile(12)}
          {this.renderTile(13)}
          {this.renderTile(14)}
          {this.renderTile(15)}
        </div>
        <br />
        <div>
	  <button 
            className="restartButton" 
            onClick={this.restartGame.bind(this)}>
              Restart game
          </button>
        </div>
      </div>
    );
  }
}

class Game extends React.Component {
  render() {
    return(
      <div className="memory-game">
        <div className="memory-grid">
          <Grid />
        </div>
      </div>
    );
  }
}


