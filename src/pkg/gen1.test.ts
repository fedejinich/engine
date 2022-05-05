import {Dex} from '@pkmn/sim';
import {Generations} from '@pkmn/data';

import {LAYOUT, Data, Lookup} from './data';
import {Battle} from './gen1';

const BUFFER = Data.buffer([
  0xe9, 0x00, 0x62, 0x00, 0x6c, 0x00, 0x80, 0x00, 0x4c, 0x00, 0x31, 0x0a, 0x84, 0x18, 0x80, 0x0a,
  0x20, 0x07, 0xd0, 0x00, 0x08, 0x0a, 0x66, 0x64, 0xd9, 0x00, 0xfc, 0x00, 0x76, 0x00, 0xba, 0x00,
  0x52, 0x00, 0x17, 0x09, 0x28, 0x37, 0x2c, 0x16, 0x14, 0x0a, 0x44, 0x00, 0x00, 0x6a, 0x11, 0x64,
  0xe7, 0x00, 0x86, 0x00, 0xa8, 0x00, 0x7c, 0x00, 0x8a, 0x00, 0x35, 0x00, 0x32, 0x02, 0x83, 0x04,
  0xa2, 0x00, 0x15, 0x00, 0x85, 0x07, 0x99, 0x64, 0x11, 0x01, 0x9e, 0x00, 0xb2, 0x00, 0x76, 0x00,
  0xbc, 0x00, 0x2a, 0x10, 0x2d, 0x28, 0x77, 0x16, 0x7d, 0x04, 0x51, 0x00, 0x00, 0x89, 0x00, 0x64,
  0x4f, 0x01, 0xe6, 0x00, 0xe6, 0x00, 0xe6, 0x00, 0xe6, 0x00, 0xa1, 0x09, 0x86, 0x00, 0x1a, 0x0f,
  0x28, 0x0d, 0x72, 0x00, 0x00, 0x97, 0xcc, 0x64, 0xce, 0x01, 0x02, 0x01, 0xa8, 0x00, 0x62, 0x00,
  0xa8, 0x00, 0x31, 0x05, 0x4d, 0x03, 0x75, 0x02, 0x1d, 0x08, 0x87, 0x00, 0x02, 0x8f, 0x00, 0x64,
  0xe9, 0x00, 0x62, 0x00, 0x6c, 0x00, 0x80, 0x00, 0x4c, 0x00, 0x0a, 0x66, 0x00, 0xe0, 0x00, 0x00,
  0x82, 0x04, 0x30, 0xeb, 0x00, 0x2a, 0x42, 0x42, 0x31, 0x0a, 0x84, 0x18, 0x80, 0x0a, 0x20, 0x07,
  0x01, 0x03, 0x02, 0x04, 0x05, 0x06, 0x1a, 0x83, 0x19, 0x01, 0x00, 0x01, 0xc4, 0x00, 0xf6, 0x00,
  0x92, 0x00, 0x3b, 0x01, 0x14, 0x1a, 0x26, 0x05, 0x46, 0x09, 0xe6, 0x00, 0x00, 0x7b, 0x26, 0x64,
  0x21, 0x01, 0xbe, 0x00, 0xbc, 0x00, 0xee, 0x00, 0xee, 0x00, 0x88, 0x09, 0x65, 0x05, 0x9e, 0x04,
  0x24, 0x1a, 0x7d, 0x00, 0x00, 0x26, 0x88, 0x64, 0x15, 0x01, 0xde, 0x00, 0xf2, 0x00, 0x98, 0x00,
  0x84, 0x00, 0x56, 0x01, 0x1f, 0x11, 0x51, 0x34, 0x11, 0x1e, 0x17, 0x00, 0x00, 0x1c, 0x44, 0x64,
  0x05, 0x01, 0x92, 0x00, 0x88, 0x00, 0x7e, 0x00, 0x74, 0x00, 0x6f, 0x2d, 0x8b, 0x27, 0x41, 0x1a,
  0x55, 0x16, 0x85, 0x00, 0x00, 0x30, 0x36, 0x64, 0xe9, 0x00, 0x8a, 0x00, 0x94, 0x00, 0x62, 0x00,
  0xbc, 0x00, 0x45, 0x0b, 0x52, 0x01, 0x1e, 0x06, 0x07, 0x0b, 0xc1, 0x00, 0x02, 0x2b, 0x3a, 0x64,
  0xdf, 0x00, 0x8c, 0x00, 0x6a, 0x00, 0x7e, 0x00, 0x6a, 0x00, 0x79, 0x06, 0x16, 0x00, 0xa5, 0x05,
  0x08, 0x0a, 0x82, 0x00, 0x00, 0x20, 0x33, 0x64, 0x19, 0x01, 0x86, 0x00, 0xa8, 0x00, 0x7c, 0x00,
  0x8a, 0x00, 0x07, 0x99, 0x00, 0x00, 0x00, 0x03, 0x21, 0x00, 0x22, 0x64, 0x00, 0x00, 0x00, 0x00,
  0x35, 0x05, 0x32, 0x05, 0x83, 0x05, 0xa2, 0x05, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x41, 0x79,
  0x61, 0x02, 0x54, 0x00, 0x00, 0x72, 0x9b, 0x2a, 0x4e, 0xfd, 0x13, 0x75, 0x25, 0xfd, 0x69, 0x08,
]);

const P1_ORDER = LAYOUT[0].offsets.Battle.p1 + LAYOUT[0].offsets.Side.order;

describe('Gen 1', () => {
  const gens = new Generations(Dex as any);
  const gen = gens.get(1);
  const lookup = Lookup.get(gen);

  it('serialize/deserialize', () => {
    const battle = new Battle(lookup, new DataView(BUFFER.buffer), {});
    const restored = Battle.restore(gen, lookup, battle, {});
    // NOTE: Jest object diffing toJSON is super slow so we compare strings instead...
    expect(JSON.stringify(restored, null, 2)).toEqual(JSON.stringify(battle, null, 2));

    expect(battle.turn).toBe(609);
    expect(battle.lastDamage).toBe(84);
    expect(battle.prng).toEqual([
      253, 105, 114, 155, 42,
      78, 253, 19, 117, 37,
    ]);

    const p1 = battle.side('p1');
    expect(p1.lastUsedMove).toBe('spikecannon');

    const slot1 = p1.active!;
    const slot2 = p1.get(2)!;

    expect(slot1.species).toBe('caterpie');
    expect(slot1.stored.species).toBe('caterpie');
    expect(slot1.hp).toBe(208);
    expect(slot1.status).toBe('tox');
    expect(slot1.statusData.toxic).toBe(4);
    expect(slot1.volatiles).toEqual({
      confusion: {duration: 2},
      thrashing: {duration: 3, accuracy: 235},
      substitute: {hp: 42},
    });
    expect(slot1.stats.atk).toBe(98);
    expect(slot1.stored.stats.atk).toBe(98);
    expect(slot1.boost('spa')).toBe(-2);
    expect(slot1.move(1)).toEqual({id: 'sonicboom', pp: 10});
    expect(slot1.move(2)).toEqual({id: 'constrict', pp: 24, disabled: 4});
    expect(slot1.active).toBe(true);

    expect(slot2.species).toBe('squirtle');
    expect(slot2.stored.species).toBe('squirtle');
    expect(slot2.types).toEqual(['Water', 'Water']);
    expect(slot2.hp).toBe(21);
    expect(slot2.status).toBe('slp');
    expect(slot2.statusData.self).toBe(true);
    expect(slot2.statusData.sleep).toBe(5);
    expect(slot2.active).toBe(false);

    const p2 = battle.foe('p1');
    expect(p2.lastSelectedMove).toBe('drillpeck');
    expect(p2.active!.species).toBe('squirtle');
    expect(p2.active!.stored.species).toBe('scyther');
    expect(p2.active!.types).toEqual(['Water', 'Water']);
    expect(p2.active!.stored.types).toEqual(['Bug', 'Flying']);
    expect(p2.active!.hp).toBe(230);
    expect(p2.active!.stats.spa).toBe(138);
    expect(p2.active!.stored.stats.spa).toBe(146);
    expect(p2.active!.move(2)).toEqual({id: 'disable', pp: 5});
    expect(p2.active!.stored.move(2)).toEqual({id: 'bind', pp: 26});
    expect(p2.active!.boosts.evasion).toBe(0);
    expect(p2.active!.volatiles).toEqual({
      bide: {damage: 100},
      trapping: {duration: 2},
      transform: {player: 'p1', slot: 2},
    });
    const boosts = Array.from(Object.values(p2.active!.boosts));
    expect(boosts.every(b => b === 0)).toBe(true);

    const pos = BUFFER[P1_ORDER];
    BUFFER[P1_ORDER] = BUFFER[P1_ORDER + 1];
    BUFFER[P1_ORDER + 1] = pos;

    expect(slot1.active).toBe(false);
    expect(slot1.boosts.spd).toBe(0);
    expect(slot2.active).toBe(true);
    expect(slot2.boosts.spd).toBe(-2);
    expect(slot2.species).toBe('caterpie');
    expect(slot2.stored.species).toBe('squirtle');
  });
});
