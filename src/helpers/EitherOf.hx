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