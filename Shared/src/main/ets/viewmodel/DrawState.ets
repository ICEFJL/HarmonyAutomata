import { State } from '../automaton/State';
import { Const } from '../common/Constants';
import { IDraw } from './IDraw';


export class DrawState extends IDraw {
  state: State;
  isInitialState: boolean;
  radius: number = Const.CIRCLE_RADIUS;

  constructor(
    state: State,
    isInitialState: boolean,
  ) {
    super();
    this.state = state;
    this.isInitialState = isInitialState;
  }

  draw(context: CanvasRenderingContext2D): void {
    // Draw the outer circle
    context.beginPath();
    context.lineWidth = Const.LINE_WIDTH;
    context.strokeStyle = Color.Black;
    context.arc(this.state.x, this.state.y, this.radius, 0, 2 * Math.PI);
    context.stroke();

    // Draw the inner circle
    context.beginPath();
    context.arc(this.state.x, this.state.y, this.radius - Const.LINE_WIDTH / 2, 0, 2 * Math.PI);
    context.fillStyle = Color.Orange;
    context.fill();

    // Draw the label
    context.font = Const.LABEL_FONT;
    context.fillStyle = Color.Black;
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(this.state.name, this.state.x, this.state.y);

    // Draw initial state marker
    if (this.isInitialState) {
      context.beginPath();
      context.moveTo(this.state.x - 2 * this.radius, this.state.y - this.radius);
      context.lineTo(this.state.x - this.radius, this.state.y);
      context.lineTo(this.state.x - 2 * this.radius, this.state.y + this.radius);
      context.lineTo(this.state.x - 2 * this.radius, this.state.y - this.radius);
      context.stroke();
    }

    // Draw final state marker
    if (this.state.isFinal) {
      context.beginPath();
      context.lineWidth = Const.LINE_WIDTH;
      context.arc(this.state.x, this.state.y, this.radius - Const.LINE_WIDTH * 2, 0, 2 * Math.PI);
      context.stroke();
    }
  }

  public equals(obj: DrawState): boolean {
    if (obj instanceof DrawState) {
      return this.state.equals(obj.state) && this.isInitialState === obj.isInitialState;
    } else {
      return false;
    }
  }

  public static deepCopy(drawState: DrawState): DrawState {
    return new DrawState(State.deepCopy(drawState.state), drawState.isInitialState);
  }
}