package org.metasyntactic.recreation.life;

import org.apache.commons.collections.map.MultiValueMap;

import java.math.BigInteger;

public class Leaf extends AbstractNode {
    private final long quadrants;
    private final char oneGenerationLater;

    private Leaf(int northWest, int northEast, int southWest, int southEast) {
        this((char) northWest, (char) northEast, (char) southWest, (char) southEast);
    }

    private Leaf(char northWest, char northEast, char southWest, char southEast) {
        quadrants = ((long) northWest << 48) | ((long) northEast << 32) | ((long) southWest << 16) | southEast;

        short t00 = liferules[northWest],
                t01 = liferules[((northWest << 2) & 0xcccc) | ((northEast >> 2) & 0x3333)],
                t02 = liferules[northEast],
                t10 = liferules[((northWest << 8) & 0xff00) | ((southWest >> 8) & 0x00ff)],
                t11 = liferules[((northWest << 10) & 0xcc00) | ((northEast << 6) & 0x3300) |
                        ((southWest >> 6) & 0x00cc) | ((southEast >> 10) & 0x0033)],
                t12 = liferules[((northEast << 8) & 0xff00) | ((southEast >> 8) & 0x00ff)],
                t20 = liferules[southWest],
                t21 = liferules[((southWest << 2) & 0xcccc) | ((southEast >> 2) & 0x3333)],
                t22 = liferules[southEast];

        oneGenerationLater =
                (char) ((t00 << 15) | (t01 << 13) | ((t02 << 11) & 0x1000) |
                        ((t10 << 7) & 0x880) | (t11 << 5) | ((t12 << 3) & 0x110) |
                        ((t20 >>> 1) & 0x8) | (t21 >>> 3) | (t22 >>> 5));
    }


    public boolean isEmpty() {
        return quadrants == 0;
    }

    public static Leaf newLeaf(int northWest, int northEast, int southWest, int southEast) {
        if (northEast == 0 && northWest == 0 &&
                southEast == 0 && southWest == 0) {
            return empty;
        }
        Leaf leaf = new Leaf(northWest, northEast, southWest, southEast);

        return (Leaf) Universe.lookupNode(leaf);
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Leaf)) return false;

        Leaf leaf = (Leaf) o;

        return quadrants == leaf.quadrants;
    }

    public int hashCode() {
        return (int) (quadrants | (quadrants >> 32));
    }

    public int depth() {
        return 2;
    }

    private final static Leaf empty = new Leaf(0, 0, 0, 0);

    static {
        Universe.lookupNode(empty);
    }

    public static Leaf emptyLeaf() {
        return empty;
    }

    public Node push() {
        return Node.newNode(
                Leaf.newLeaf(0, 0, 0, getNorthWest()),
                Leaf.newLeaf(0, 0, getNorthEast(), 0),
                Leaf.newLeaf(0, getSouthWest(), 0, 0),
                Leaf.newLeaf(getSouthEast(), 0, 0, 0));
    }

    private final static BigInteger EIGHT = new BigInteger("8");

    public boolean getValue(BigInteger bigX, BigInteger bigY) {
        assert bigX.compareTo(BigInteger.ZERO) >= 0;
        assert bigX.compareTo(EIGHT) < 0;
        assert bigY.compareTo(BigInteger.ZERO) >= 0;
        assert bigY.compareTo(EIGHT) < 0;

        int x = bigX.intValue();
        int y = bigY.intValue();

        return getValue(x, y);
    }

    private boolean getValue(int x, int y) {
        char quadrant;
        int offsetX = x;
        int offsetY = y;

        if (offsetX >= 4) {
            offsetX -= 4;
        }

        if (offsetY >= 4) {
            offsetY -= 4;
        }

        offsetX = 3 - offsetX;
        offsetY = 3 - offsetY;

        if (x < 4) {
            if (y < 4) {
                quadrant = getNorthWest();
            } else {
                quadrant = getSouthWest();
            }
        } else {
            if (y < 4) {
                quadrant = getNorthEast();
            } else {
                quadrant = getSouthEast();
            }
        }

        int bit = offsetY * 4 + offsetX;
        return ((quadrant >>> bit) & 0x1) == 1;
    }

    public Leaf setValue(BigInteger bigX, BigInteger bigY, boolean value) {
        assert bigX.compareTo(BigInteger.ZERO) >= 0;
        assert bigX.compareTo(EIGHT) < 0;
        assert bigY.compareTo(BigInteger.ZERO) >= 0;
        assert bigY.compareTo(EIGHT) < 0;

        int x = bigX.intValue();
        int y = bigY.intValue();

        return setValue(x, y, value);
    }

    private Leaf setValue(int x, int y, boolean value) {
        int offsetX = x;
        int offsetY = y;

        if (offsetX >= 4) {
            offsetX -= 4;
        }

        if (offsetY >= 4) {
            offsetY -= 4;
        }

        offsetX = 3 - offsetX;
        offsetY = 3 - offsetY;

        char newNW = getNorthWest(), newNE = getNorthEast(),
                newSW = getSouthWest(), newSE = getSouthEast();

        int bit = offsetY * 4 + offsetX;
        int mask = 1 << bit;
        if (value == false) {
            mask = ~mask;
        }

        if (x < 4) {
            if (y < 4) {
                newNW = setBit(value, mask, getNorthWest());
            } else {
                newSW = setBit(value, mask, getSouthWest());
            }
        } else {
            if (y < 4) {
                newNE = setBit(value, mask, getNorthEast());
            } else {
                newSE = setBit(value, mask, getSouthEast());
            }
        }

        return Leaf.newLeaf(newNW, newNE, newSW, newSE);
    }

    private char setBit(boolean value, int mask, char quadrant) {
        return (char) (value ? (quadrant | mask) : (quadrant & mask));
    }

    public double coverageWorker() {
        return (coverage(getNorthWest()) + coverage(getNorthEast()) +
                coverage(getSouthWest()) + coverage(getSouthEast())) / 4.0;
    }

    private double coverage(char quadrant) {
        int count = 0;
        while (quadrant > 0) {
            count += quadrant & 0x1;
            quadrant >>= 1;
        }

        return (double) count / 4.0;
    }

    public Leaf canonicalize() {
        return newLeaf(getNorthWest(), getNorthEast(), getSouthWest(), getSouthEast());
    }

    protected int getLiveLocations(int xStart, int yStart, MultiValueMap map) {
        final int heightWidth = 8;
        if (!isEmpty()) {
            for (int x = 0; x < heightWidth; x++) {
                for (int y = 0; y < heightWidth; y++) {
                    boolean value = getValue(x, y);

                    if (value) {
                        map.put(x + xStart, y + yStart);
                    }
                }
            }
        }

        return heightWidth;
    }

    public final char getNorthWest() {
        return (char) (quadrants >>> 48);
    }

    public final char getNorthEast() {
        return (char) (quadrants >>> 32);
    }

    public final char getSouthWest() {
        return (char) (quadrants >>> 16);
    }

    public final char getSouthEast() {
        return (char) quadrants;
    }

    public final char getOneGenerationLater() {
        return oneGenerationLater;
    }
}