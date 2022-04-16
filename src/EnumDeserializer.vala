using GLib;

namespace LazTools.Text.Json
{
	public class EnumDeserializer : Object, IJsonTypeDeserializer, IFullTypeDeserializer
	{
		public bool CanHandleType(Type t)
		{
			return t.is_enum();
		}

		public Value DeserializeIntoValue(Type targetType, JsonReader reader, JsonContext ctx)
		{
			Value v = Value(targetType);

			if(!reader.Proceed())
				throw new JsonError.INVALID_JSON("Change this error. Cannot read enum");

			if(ctx.HandleEnumAsString)
			{
				string enumNick = reader.ReadString();
				EnumClass enumClass = (EnumClass)targetType.class_ref();
				EnumValue? enumValue = enumClass.get_value_by_nick(enumNick);
				if(enumValue == null)
					throw new JsonError.INVALID_JSON("Unknown enum member.");

				v.set_enum(enumValue.value);
			}
			else
			{
				int enumNumberValue = reader.ReadInt32();
				v.set_enum(enumNumberValue);
			}

			return v;
		}
	}
}
