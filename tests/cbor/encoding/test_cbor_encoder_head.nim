import std/[sequtils, unittest]
import surreal/private/stew/sequtils2
import surreal/private/cbor/[constants, encoder, types, writer]

suite "CBOR:Encoder:Head":

    test "encodeHeadByte should properly encode the the first byte":
        check(encodeHeadByte(PosInt, Zero) == 0b000_00000'u8)
        check(encodeHeadByte(PosInt, One) == 0b000_00001'u8)
        check(encodeHeadByte(PosInt, TwoBytes) == 0b000_11001'u8)
        check(encodeHeadByte(NegInt, Zero) == 0b001_00000'u8)
        check(encodeHeadByte(NegInt, Ten) == 0b001_01010'u8)
        check(encodeHeadByte(NegInt, Indefinite) == 0b001_11111'u8)
        check(encodeHeadByte(Bytes, Six) == 0b010_00110'u8)
        check(encodeHeadByte(String, EightBytes) == 0b011_11011'u8)
        check(encodeHeadByte(Array, Reserved30) == 0b100_11110'u8)
        check(encodeHeadByte(Map, Two) == 0b101_00010'u8)
        check(encodeHeadByte(Tag, Seven) == 0b110_00111'u8)
        check(encodeHeadByte(Simple, Eight) == 0b111_01000'u8)
        check(encodeHeadByte(Simple, Indefinite) == 0b111_11111'u8)
        check(cborBreak == 0b111_11111'u8)

    test "writer's encodeHeadByte should properly encode the the first byte":
        var writer = newCborWriter()
        writer.encodeHeadByte(PosInt, Zero)
        check(writer.getOutput()[0] == 0b000_00000'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(PosInt, One)
        check(writer.getOutput()[0] == 0b000_00001'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(PosInt, TwoBytes)
        check(writer.getOutput()[0] == 0b000_11001'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(NegInt, Zero)
        check(writer.getOutput()[0] == 0b001_00000'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(NegInt, Ten)
        check(writer.getOutput()[0] == 0b001_01010'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(NegInt, Indefinite)
        check(writer.getOutput()[0] == 0b001_11111'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(Bytes, Six)
        check(writer.getOutput()[0] == 0b010_00110'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(String, EightBytes)
        check(writer.getOutput()[0] == 0b011_11011'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(Array, Reserved30)
        check(writer.getOutput()[0] == 0b100_11110'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(Map, Two)
        check(writer.getOutput()[0] == 0b101_00010'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(Tag, Seven)
        check(writer.getOutput()[0] == 0b110_00111'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(Simple, Eight)
        check(writer.getOutput()[0] == 0b111_01000'u8)

        writer = newCborWriter()
        writer.encodeHeadByte(Simple, Indefinite)
        check(writer.getOutput()[0] == 0b111_11111'u8)

        check(cborBreak == 0b111_11111'u8)

    test "encodeHead should properly encode the major":
        var numbers: seq[uint64] = @[]
        numbers.write (0'u64..7'u64).toSeq
        numbers.write [255'u64, 256'u64, 257'u64, uint16.high.uint64, uint32.high.uint64, uint64.high.uint64]

        for argument in numbers:
            var writer = newCborWriter()
            writer.encodeHead(PosInt, argument)
            var head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b000_00000'u8)

            writer = newCborWriter()
            writer.encodeHead(NegInt, argument)
            head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b001_00000'u8)

            writer = newCborWriter()
            writer.encodeHead(Bytes, argument)
            head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b010_00000'u8)

            writer = newCborWriter()
            writer.encodeHead(String, argument)
            head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b011_00000'u8)

            writer = newCborWriter()
            writer.encodeHead(Array, argument)
            head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b100_00000'u8)

            writer = newCborWriter()
            writer.encodeHead(Map, argument)
            head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b101_00000'u8)

            writer = newCborWriter()
            writer.encodeHead(Tag, argument)
            head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b110_00000'u8)

            writer = newCborWriter()
            writer.encodeHead(Simple, argument)
            head = writer.getOutput()
            check((head[0] and 0b111_00000'u8) == 0b111_00000'u8)

    test "encodeHead should properly encode the argument":
        for major in PosInt..Simple:
            for argument in Zero..TwentyThree:
                let writer = newCborWriter()
                writer.encodeHead(major, argument.uint64)
                let head = writer.getOutput()
                let expectedFirstByte = encodeHeadByte(major, argument)
                check(head[0] == expectedFirstByte)
                check(head.len == 1)

        var writer = newCborWriter()
        writer.encodeHead(PosInt, 24)
        check(writer.getOutput() == @[0b000_11000'u8, 0b0001_1000])

        writer = newCborWriter()
        writer.encodeHead(Bytes, 25)
        check(writer.getOutput() == @[0b010_11000'u8, 0b0001_1001])

        writer = newCborWriter()
        writer.encodeHead(String, 100)
        check(writer.getOutput() == @[0b011_11000'u8, 0b0110_0100])

        writer = newCborWriter()
        writer.encodeHead(NegInt, 255)
        check(writer.getOutput() == @[0b001_11000'u8, 0xFF])

        writer = newCborWriter()
        writer.encodeHead(Array, 256)
        check(writer.getOutput() == @[0b100_11001'u8, 0x01, 0x00])

        writer = newCborWriter()
        writer.encodeHead(Map, 10_000)
        check(writer.getOutput() == @[0b101_11001'u8, 0x27, 0x10])

        writer = newCborWriter()
        writer.encodeHead(Map, uint16.high.uint64)
        check(writer.getOutput() == @[0b101_11001'u8, 0xFF, 0xFF])

        writer = newCborWriter()
        writer.encodeHead(Tag, uint16.high.uint64 + 1)
        check(writer.getOutput() == @[0b110_11010'u8, 0x00, 0x01, 0x00, 0x00])

        writer = newCborWriter()
        writer.encodeHead(Simple, 1_000_000_000)
        check(writer.getOutput() == @[0b111_11010'u8, 0x3B, 0x9A, 0xCA, 0x00])

        writer = newCborWriter()
        writer.encodeHead(Bytes, uint32.high.uint64)
        check(writer.getOutput() == @[0b010_11010'u8, 0xFF, 0xFF, 0xFF, 0xFF])

        writer = newCborWriter()
        writer.encodeHead(Simple, uint32.high.uint64 + 1)
        check(writer.getOutput() == @[0b111_11011'u8, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00])

        writer = newCborWriter()
        writer.encodeHead(Tag, 6_942_069_420_694_206_942'u64)
        check(writer.getOutput() == @[0b110_11011'u8, 0x60, 0x57, 0x2F, 0x5B, 0x82, 0x94, 0x79, 0xDE])

        writer = newCborWriter()
        writer.encodeHead(NegInt, uint64.high)
        check(writer.getOutput() == @[0b001_11011'u8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
