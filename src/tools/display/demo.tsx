// @ts-ignore
import FuzzySearch from 'fz-search';
console.log(FuzzySearch);

import * as engine from '../../pkg';
import * as gen1 from '../../pkg/gen1';

// import {AutoComplete} from './autocomplete';
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

const buf = Uint8Array.from(atob(json.buf), c => c.charCodeAt(0));
document.getElementById('content')!.appendChild(<App
  gen={GEN}
  data={new DataView(buf.buffer, buf.byteOffset, buf.byteLength)}
  showdown={json.showdown}
/>);

// const SpeciesSelect = () => {
//   // const options = Array.from(gen.species).map(s => <option value={s.id}>{s.name}</option>);
//   // return <select name="species" id="species">{options}</select>;

//   const searcher = new FuzzySearch({
//     source: order.species,
//     token_field_min_length: 1,
//     sorter: (a: any, b: any) => b.score - a.score,
//   });

//   const input = <input type="text" name="q" placeholder="Tauros" ></input>;
//   const _ = new AutoComplete(input,
//     function (term, suggest) {
//       suggest(searcher.search(term));
//     }, {
//       minChars: 1,
//       renderItem(item: string) {
//         return '<div class="autocomplete-suggestion" data-val="' + item + '">' +
//         searcher.highlight(item) + '</div>';
//       },
//     });
//   return input;
// };

// document.getElementById('content')!.appendChild(<SpeciesSelect />);
