package tests;

import Bun.fetchJson;
import Bun.fetch;
import bun.Shell;
import helpers.ResultPromise;
import haxe.ds.Option;
import haxe.io.Bytes;
import js.lib.Promise;
import result.Result;
import sys.io.File;
import sys.FileSystem;
import tests.PokeApiType;
import tink.validation.Validator;
import tink.Validation;
import utest.Assert;
import utest.Test;
import haxe.Json;

using ResultTools;

function testFetch(async:utest.Async) {
	final jsonObjPromise = fetchJson('https://pokeapi.co/api/v2/pokemon/ditto').then(result -> {
		switch (result) {
			case Ok(rawObject):
				trace('Is a Ditto: ${(rawObject : PokeApiType).name == "ditto"}');

			case Error(_):
				trace("Api call failed");
		}
	});
}

class TestFetch extends Test {
	@:timeout(3000) function testRawFetch(async:utest.Async) {
		final cmd = fetch('https://pokeapi.co/api/v2/pokemon/ditto').then(v -> {
			switch (v) {
				case Ok(response): response.json().then(jsonObj -> {
						Assert.equals("ditto", jsonObj.name);
						async.done();
					});
				case Error(_):
					Assert.fail("fetch failed");
					async.done();
			}
		});
	}

	@:timeout(3000) function testJsonFetch(async:utest.Async) {
		final cmd = fetchJson('https://pokeapi.co/api/v2/pokemon/cyndaquil').then(v -> {
			switch (v) {
				case Ok(rawObject):
					final validatedObj:PokeApiType = Validation.extract(rawObject);
					Assert.equals("cyndaquil", validatedObj.name);
					async.done();
				case Error(e):
					trace(e);
					Assert.fail("fetch failed");
					async.done();
			}
		});
	}

	private function validate(obj:Any):Option<PokeApiType> {
		try {
			final pokemonData:PokeApiType = Validation.extract(obj);
			return Some(pokemonData);
		} catch (_) {
			return Option.None;
		}
	}

	@:timeout(3000) function testJsonFetchWithPromiseHelpers(async:utest.Async) {
		final maybePokemonObj = fetchJson('https://pokeapi.co/api/v2/pokemon/mudkip').map(validate).then(maybePokemonObj -> {
			Assert.isTrue(maybePokemonObj.isOk());
			async.done();
		});
	}

	@:timeout(3000) function testJsonFetchError(async:utest.Async) {
		final cmd = fetchJson('http://invalid_url_string/').then(v -> {
			switch (v) {
				case Ok(rawObject):
					Assert.fail("fetchJson should fail for an invalid url");
					async.done();
				case Error(e):
					Assert.isTrue(e.match(FailedToConnect(_)));
					async.done();
			}
		});
	}

	@:timeout(3000) function testJsonFetchErrorWithHelpers(async:utest.Async) {
		final maybeObjectPromise = fetchJson('http://invalid_url_string/').map(validate);
		maybeObjectPromise.then(maybeObject -> {
			Assert.isFalse(maybeObject.isOk());
			async.done();
		});
	}
}
