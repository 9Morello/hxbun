package tests;

typedef PokeApiType = {
	abilities:Array<{
		ability:{
			name:String,
			url:String
		},
		is_hidden:Bool,
		slot:Int
	}>,
	base_experience:Int,
	cries:{
		latest:String, legacy:String
	},
	forms:Array<{
		name:String,
		url:String
	}>,
	game_indices:Array<{
		game_index:Int,
		version:{
			name:String,
			url:String
		}
	}>,
	height:Int,
	held_items:Array<Dynamic>,
	id:Int,
	is_default:Bool,
	location_area_encounters:String,
	moves:Array<{
		move:{
			name:String,
			url:String
		},
		version_group_details:Array<{
			level_learned_at:Int,
			move_learn_method:{
				name:String,
				url:String
			},
			version_group:{
				name:String,
				url:String
			}
		}>
	}>,
	name:String,
	order:Int,
	past_abilities:Array<Dynamic>,
	past_types:Array<Dynamic>,
	species:{
		name:String, url:String
	},
	sprites:{
		back_default:String, back_female:Dynamic, back_shiny:String, back_shiny_female:Dynamic, front_default:String, front_female:Dynamic, front_shiny:String,
		front_shiny_female:Dynamic, other:{
			dream_world:{
				front_default:String, front_female:Dynamic
			}, home:{
				front_default:String, front_female:Dynamic, front_shiny:String, front_shiny_female:Dynamic
			}, showdown:{
				back_default:String, back_female:Dynamic, back_shiny:String, back_shiny_female:Dynamic, front_default:String, front_female:Dynamic,
				front_shiny:String, front_shiny_female:Dynamic
			}
		}
	},
	stats:Array<{
		base_stat:Int,
		effort:Int,
		stat:{
			name:String,
			url:String
		}
	}>,
	types:Array<{
		slot:Int,
		type:{
			name:String,
			url:String
		}
	}>,
	weight:Int
}
