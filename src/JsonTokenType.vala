namespace LazTools.Text.Json
{
	public enum JsonTokenType
	{
		DocumentStart,
		ObjectStart,
		ArrayStart,
		Boolean,
		Number,
		String,
		Null,
		Property,
		ObjectEnd,
		ArrayEnd,
		DocumentEnd
	}
}
