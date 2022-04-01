using GLib;

namespace LazTools.Json
{
	public interface IJsonTypeSerializer : Object
	{
		public abstract bool CanHandleType(Type type);

		public abstract void SerializeValue(Value value, Type valueType, JsonWriter writer);
	}
}
