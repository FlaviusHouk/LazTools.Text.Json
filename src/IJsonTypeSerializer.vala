using GLib;

namespace LazTools.Text.Json
{
	public interface IJsonTypeSerializer : Object
	{
		public abstract bool CanHandleType(Type type);

		public abstract void SerializeValue(Value value, Type valueType, JsonWriter writer, JsonContext ctx);
	}
}
