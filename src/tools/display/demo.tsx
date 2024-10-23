import * as engine from '../../pkg';
import * as gen1 from '../../pkg/gen1';

// import {Select} from './select';
import {Battle, Gen, Generation, adapt} from './ui';

const App = ({gen, data, showdown}: {gen: Generation; data: DataView; showdown: boolean}) => {
  const lookup = engine.Lookup.get(gen);
  const deserialize = (d: DataView): engine.Battle => {
    switch (gen.num) {
      case 1: return new gen1.Battle(lookup, d, {showdown});
      default: throw new Error(`Unsupported gen: ${gen.num}`);
    }
  };
  const battle = deserialize(data);
  return <Battle battle={battle} gen={gen} showdown={showdown} hide={true} />;
};

const json = (window as any).DATA;
const wasm = (window as any).WASM;
const GEN = adapt(new Gen(json.gen));

const lookup = engine.Lookup.get(GEN);
const order: {species: string[]; moves: {[id: string]: string[]}} = {species: [], moves: {}};

let offset = 0;
const species = atob(json.order.species);
const moves = atob(json.order.moves);
for (let i = 0; i < species.length; i++) {
  const id = lookup.speciesByNum(species.charCodeAt(i));
  const specie = GEN.species.get(id)!;
  order.species.push(specie.name);

  const ids = [];
  for (; offset < moves.length && moves.charCodeAt(offset) !== 0; offset++) {
    ids.push(lookup.moveByNum(moves.charCodeAt(offset)));
  }
  offset++;
  order.moves[specie.id] = ids;
}

console.debug(order);

const bytes = Uint8Array.from(atob(wasm), c => c.charCodeAt(0));
engine.initialize(json.showdown, new WebAssembly.Module(bytes)).then(() => {
  const buf = Uint8Array.from(atob(json.buf), c => c.charCodeAt(0));
  document.getElementById('content')!.appendChild(<App
    gen={GEN}
    data={new DataView(buf.buffer, buf.byteOffset, buf.byteLength)}
    showdown={json.showdown}
  />);
}).catch(console.error);

// const select = <Select options={order.species} placeholder='Tauros' />;

// document.getElementById('content')!.appendChild(select);
