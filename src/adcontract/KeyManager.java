package adcontract;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Arrays;


public final class KeyManager {

    private static final String ALGORITHM = "RSA";
    private static final int KEY_SIZE = 2048;

    private static final String BRAND_PUBLIC      = "brand_public.key";
    private static final String BRAND_PRIVATE     = "brand_private.key";
    private static final String INFLUENCER_PUBLIC = "influencer_public.key";
    private static final String INFLUENCER_PRIVATE = "influencer_private.key";

    private KeyManager() {
    }

    public static void generateAndSaveAllKeys(String dataDir)
            throws GeneralSecurityException, IOException {
        ensureDir(dataDir);

        KeyPair brandKeyPair = generateKeyPair();
        savePublicKey(brandKeyPair.getPublic(), dataDir + "/" + BRAND_PUBLIC);
        savePrivateKey(brandKeyPair.getPrivate(), dataDir + "/" + BRAND_PRIVATE);

        KeyPair influencerKeyPair = generateKeyPair();
        savePublicKey(influencerKeyPair.getPublic(), dataDir + "/" + INFLUENCER_PUBLIC);
        savePrivateKey(influencerKeyPair.getPrivate(), dataDir + "/" + INFLUENCER_PRIVATE);
    }

    public static KeyPair generateKeyPair() throws NoSuchAlgorithmException {
        KeyPairGenerator generator = KeyPairGenerator.getInstance(ALGORITHM);
        generator.initialize(KEY_SIZE);
        return generator.generateKeyPair();
    }

    public static void savePublicKey(PublicKey publicKey, String filePath) throws IOException {
        Files.write(Paths.get(filePath), publicKey.getEncoded());
    }

    public static void savePrivateKey(PrivateKey privateKey, String filePath) throws IOException {
        byte[] encoded = privateKey.getEncoded();
        try {
            Files.write(Paths.get(filePath), encoded);
        } finally {
            Arrays.fill(encoded, (byte) 0);
        }
    }

    public static PublicKey loadPublicKey(String filePath)
            throws GeneralSecurityException, IOException {
        byte[] keyBytes = Files.readAllBytes(Paths.get(filePath));
        X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance(ALGORITHM);
        return keyFactory.generatePublic(spec);
    }

    public static PrivateKey loadPrivateKey(String filePath)
            throws GeneralSecurityException, IOException {
        byte[] keyBytes = Files.readAllBytes(Paths.get(filePath));
        try {
            PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
            KeyFactory keyFactory = KeyFactory.getInstance(ALGORITHM);
            return keyFactory.generatePrivate(spec);
        } finally {
            Arrays.fill(keyBytes, (byte) 0); 
        }
    }

    public static boolean keysExist(String dataDir) {
        return new File(dataDir + "/" + BRAND_PUBLIC).exists()
                && new File(dataDir + "/" + BRAND_PRIVATE).exists()
                && new File(dataDir + "/" + INFLUENCER_PUBLIC).exists()
                && new File(dataDir + "/" + INFLUENCER_PRIVATE).exists();
    }

    private static void ensureDir(String dataDir) throws IOException {
        File dir = new File(dataDir);
        if (!dir.exists() && !dir.mkdirs()) {
            throw new IOException("data 디렉터리를 생성하지 못했습니다: " + dir.getAbsolutePath());
        }
    }
}
