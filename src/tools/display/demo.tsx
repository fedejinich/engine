import * as engine from '../../pkg';
import * as gen1 from '../../pkg/gen1';

import {Battle, Gen, Generation, adapt} from './ui';

const App = ({gen, data, showdown}: {gen: Generation; data: DataView; showdown: boolean}) => {
  const lookup = engine.Lookup.get(gen);
  const deserialize = (d: DataView): engine.Battle => {
    switch (gen.num) {
      // FIXME: not actually inert..
      case 1: return new gen1.Battle(lookup, d, {inert: true, showdown});
      default: throw new Error(`Unsupported gen: ${gen.num}`);
    }
  };
  const battle = deserialize(data);
  return <Battle battle={battle} gen={gen} showdown={showdown} hide={true} />;
};

const json = (window as any).DATA;
const GEN = adapt(new Gen(json.gen));

const lookup = engine.Lookup.get(GEN);
const raw = atob(json.order);
const order: {[id: string]: string[]} = {};
let i = 0;
for (const s of GEN.species) {
  const moves = [];
  for (; i < raw.length && raw.charCodeAt(i) !== 0; i++) {
    moves.push(lookup.moveByNum(raw.charCodeAt(i)));
  }
  order[s.id] = moves;
  i++;
}
console.debug(order);

const buf = Uint8Array.from(atob(json.buf), c => c.charCodeAt(0));
document.getElementById('content')!.appendChild(<App
  gen={GEN}
  data={new DataView(buf.buffer, buf.byteOffset, buf.byteLength)}
  showdown={json.showdown}
/>);
