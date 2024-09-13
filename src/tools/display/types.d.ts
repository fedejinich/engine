// Simplified type definitions for the fz-search features required by select.tsx
declare module 'fz-search' {
  export default class FuzzySearch<T> {
    readonly query: string | null;
    constructor(options: {
      source: T[];
      token_field_min_length?: number;
      sorter?: (a: {score: number}, b: {score: number}) => number;
    });
    search(pattern: string): T[];
    highlight(value: string): string;
  }
}
