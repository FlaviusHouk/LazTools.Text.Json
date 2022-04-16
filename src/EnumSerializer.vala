using GLib;

namespace LazTools.Text.Json
{
	public class EnumSerializer : Object, IJsonTypeSerializer
	{
		public bool CanHandleType(Type type)
		{
			return type.is_enum();
		}

		public void SerializeValue(Value value, Type valueType, JsonWriter writer, JsonContext ctx)
		{
			int enumValue = value.get_enum();
			if(ctx.HandleEnumAsString)
			{
				EnumClass enumClass = (EnumClass)valueType.class_ref();
				EnumValue? enumTypeValue = enumClass.get_value(enumValue);
				if(enumTypeValue == null)
					throw new JsonError.INVALID_JSON("Change this error. Unknown enum member.");

				writer.WriteString(enumTypeValue.value_nick);
			}
			else
			{
				writer.WriteInt32(enumValue);
			}
		}
	}
}
