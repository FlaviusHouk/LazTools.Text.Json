using GLib;

namespace LazTools.Text.Json
{
	internal enum JsonReaderStateEnum
	{
		DocumentStart,
		LiteralValue,
		NumberValue,
		StringValue,
		Object,
		Array
	}
}
