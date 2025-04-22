package helpers;
import haxe.extern.EitherType;

/**
    Convenience wrapper over `haxe.extern.EitherType` that handles 3 types.
**/
typedef EitherOf3<A, B, C> = EitherType<A, EitherType<B, C>>;

/**
    Convenience wrapper over `haxe.extern.EitherType` that handles 4 types.
**/
typedef EitherOf4<A, B, C, D> = EitherType<EitherOf3<A, B, C>, D>;

/**
    Convenience wrapper over `haxe.extern.EitherType` that handles 5 types.
**/
typedef EitherOf5<A, B, C, D, E> = EitherType<EitherOf4<A, B, C, D>, E>;