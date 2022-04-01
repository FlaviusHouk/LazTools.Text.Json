namespace LazTools.Json
{
	internal enum JsonWriterState
	{
		Start,
		Primitive,
		EndObject,
		EndArray,
		Property,
		StartObject,
		StartArray
	}
}
