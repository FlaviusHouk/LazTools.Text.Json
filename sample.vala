using GLib;
using LazTools.Text.Json;

namespace LazTools
{
	public class Point
	{
		public int X;
		public int Y;
	}

	public enum PartOfTheCountryEnum
	{
		Center,
		South,
		West,
		East,
		North
	}

	public class Location : Object
	{
		public string Name { get; set; }
		public PartOfTheCountryEnum Part { get; set; }
		public Point? Coords { get; set; }
	}

	public class BIO : Object
	{
		public string Name { get; set; }
		public string LastName { get; set; }
	}

	public class TestClass : Object
	{
		public int X { get; set; }
		public double Y { get; set; }
		public bool TBool { get; set; }
		public string TString { get; set; }
		public BIO TBio { get; set; }
	}

	public class TestClass2 : Object
	{
		public TestClass Position { get; set; }
		public int Id { get; set; }
		public Point LogicalPosition { get; set; }
		public int[] Data { get; set; }
	}

	/*internal class PointStructJsonDeserializer : Object, IJsonTypeDeserializer, IFullTypeDeserializer
	{
		public bool CanHandleType(Type t)
		{
			Type currentType = typeof(Point?);
			return t.is_a(currentType);
		}

		public Value DeserializeIntoValue(Type targetType, JsonReader reader, JsonContext ctx)
		{
			Value v = Value(targetType);
			if(!reader.Proceed())
				throw new JsonError.INVALID_JSON("Expected object start");

			if(reader.Token == JsonTokenType.Null)
				return v;

			Point p = Point();
			while(reader.Proceed() && reader.Token != JsonTokenType.ObjectEnd)
			{
				string propName = reader.ReadPropertyName();

				if(!reader.Proceed())
					throw new JsonError.INVALID_JSON("Invalid Json for struct.");

				if(propName == "X")
					p.X = reader.ReadInt32();
				else if(propName == "Y")
					p.Y = reader.ReadInt32();
			}

			v.set_boxed(&p);
			return v;
		}
	}*/

	/*internal class PointClassDeserializer : Object, IJsonTypeDeserializer, IPartialTypeDeserializer
	{
		public bool CanHandleType(Type t)
		{
			Type currentType = typeof(Point?);
			return t.is_a(currentType);
		}

		public Value CreateInstance()
		{
			Value v = Value(typeof(Point));
			Point p = new Point();
			v.set_instance(p);
			return v;
		}

		public Type GetPropertyType(string propertyName)
		{
			return typeof(int);
		}

		public void SetProperty(Value instance, string propertyName, Value value)
		{
			Point? p = (Point?)instance.peek_pointer();
			if(p == null)
				return;

			if(propertyName == "X")
				p.X = value.get_int();
			else if(propertyName == "Y")
				p.Y = value.get_int();
		}
	}*/

	internal class PointJsonSerializer : JsonTypeSerializer<Point?>
	{
		public override void SerializeValue(Value value, Type valueType, JsonWriter writer, JsonContext ctx)
		{
			Serialize((Point?)value.peek_pointer(), writer, ctx);
		}

		public override void Serialize(Point? obj, JsonWriter writer, JsonContext ctx)
		{
			if(obj == null)
			{
				writer.WriteNull();
				return;
			}

			writer.StartObject();
			writer.WriteProperty("X");
			writer.WriteInt32(obj.X);
			writer.WriteProperty("Y");
			writer.WriteInt32(obj.Y);
			writer.EndObject();
		}
	}

	public class Sample : Object
	{
		public static void DoAction<T>(T obj)
		{
			Type t = typeof(T);
			stdout.printf("%s\n", t.name());
		}

		public static T ReturnType<T>(string val, int type)
		{
			if(type == 0)
			{
				return int.parse(val);
			}
			else
			{
				return (T)val;
			}
		}

		public static void main(string[] args)
		{
			//Type type = typeof(int[]);
			//TypeQuery q;
			//type.query(out q);
			//stdout.printf("%s\n", q.type_name);
	Type type = typeof (Point);
	print ("%s\n", type.name ());
	print (" is-obj: %s\n", type.is_object ().to_string ());
	print (" is-abstr: %s\n", type.is_abstract ().to_string ());
	print (" is-classed: %s\n", type.is_classed ().to_string ());
	print (" is-derivable: %s\n", type.is_derivable ().to_string ());
	print (" is-derived: %s\n", type.is_derived ().to_string ());
	print (" is-fund: %s\n", type.is_fundamental ().to_string ());
	print (" is-inst: %s\n", type.is_instantiatable ().to_string ());
	print (" is-iface: %s\n", type.is_interface ().to_string ());
	print (" is-enum: %s\n", type.is_enum ().to_string ());
	print (" is-flags: %s\n", type.is_object ().to_string ());


			/*File jsonFile = File.new_for_path("sample2.json");
			FileInputStream fileStream = jsonFile.read();

			JsonContext ctx = new JsonContext();
			PointClassDeserializer ds1 = new PointClassDeserializer();
			ctx.RegisterDeserializer(ds1);

			Value val = JsonSerializer.DeserializeFromStream(fileStream, typeof(Location), ctx);
			Location obj = (Location)val.get_object();
			print("%s: [%d;%d]\n", obj.Name, obj.Coords.X, obj.Coords.Y);

			fileStream.close();*/

			Location loc = new Location();
			loc.Name = "Mykolaiv";
			loc.Part = PartOfTheCountryEnum.South;
			loc.Coords = new Point();
			loc.Coords.X = -4;
			loc.Coords.Y = -30;

			JsonContext ctx = new JsonContext();
			ctx.HandleEnumAsString = true;
			PointJsonSerializer s1 = new PointJsonSerializer();
			EnumSerializer s2 = new EnumSerializer();
			ctx.RegisterSerializer(s1);
			ctx.RegisterSerializer(s2);

			string json = JsonSerializer.SerializeToString<Location>(loc, ctx);
			stdout.printf("%s\n", json);
		}
	}
}
