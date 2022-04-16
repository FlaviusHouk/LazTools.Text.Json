using GLib;

namespace LazTools.Text.Json
{
	public interface IFullTypeDeserializer : IJsonTypeDeserializer
	{
		public abstract Value DeserializeIntoValue(Type targetType, JsonReader reader, JsonContext ctx);
	}
}
