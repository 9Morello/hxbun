package bun;

typedef QueuingStrategy<T> = {
	?highWaterMark:Float,
	?size:(?chunk:T) -> Float
};
