package adcontract;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Signature;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;


public final class EnvelopeCreator {

    private static final Logger LOG = Logger.getLogger(EnvelopeCreator.class.getName());

    private static final String AES_ALGORITHM = "AES/GCM/NoPadding";
    private static final int AES_KEY_BITS = 256;
    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 128;

    private static final String RSA_ALGORITHM = "RSA/ECB/OAEPWithSHA-256AndMGF1Padding";
    private static final String HASH_ALGORITHM = "SHA-256";
    private static final String SIGN_ALGORITHM = "SHA256withRSA";

    private static final String CONTRACT_FILE      = "ad_contract.txt";
    private static final String ENCRYPTED_CONTRACT = "encrypted_contract.bin";
    private static final String IV_FILE            = "iv.bin";
    private static final String ENCRYPTED_AES_KEY  = "encrypted_aes_key.bin";
    private static final String CONTRACT_HASH      = "contract_hash.bin";
    private static final String BRAND_SIGNATURE    = "brand_signature.bin";
    private static final String INFLUENCER_PUBLIC  = "influencer_public.key";
    private static final String BRAND_PRIVATE      = "brand_private.key";

    private EnvelopeCreator() {
    }

    /** G24: 외부에서 수정 불가능한 불변 결과 객체 */
    public static final class EnvelopeResult {
        private final boolean success;
        private final String message;
        private final String contractPath;
        private final String encryptedContractPath;
        private final String ivPath;
        private final String encryptedAesKeyPath;
        private final String contractHashPath;
        private final String brandSignaturePath;

        private EnvelopeResult(boolean success, String message, String contractPath,
                               String encryptedContractPath, String ivPath, String encryptedAesKeyPath,
                               String contractHashPath, String brandSignaturePath) {
            this.success = success;
            this.message = message;
            this.contractPath = contractPath;
            this.encryptedContractPath = encryptedContractPath;
            this.ivPath = ivPath;
            this.encryptedAesKeyPath = encryptedAesKeyPath;
            this.contractHashPath = contractHashPath;
            this.brandSignaturePath = brandSignaturePath;
        }

        static EnvelopeResult failure(String message) {
            return new EnvelopeResult(false, message, null, null, null, null, null, null);
        }

        public boolean isSuccess()               { return success; }
        public String getMessage()               { return message; }
        public String getContractPath()          { return contractPath; }
        public String getEncryptedContractPath() { return encryptedContractPath; }
        public String getIvPath()                { return ivPath; }
        public String getEncryptedAesKeyPath()   { return encryptedAesKeyPath; }
        public String getContractHashPath()      { return contractHashPath; }
        public String getBrandSignaturePath()    { return brandSignaturePath; }
    }

    public static EnvelopeResult createEnvelope(String dataDir) {
        byte[] contractBytes = null;
        byte[] aesKeyBytes = null;
        try {
            contractBytes = Files.readAllBytes(Paths.get(dataDir + "/" + CONTRACT_FILE));

            KeyGenerator keyGen = KeyGenerator.getInstance("AES");
            keyGen.init(AES_KEY_BITS);
            SecretKey aesKey = keyGen.generateKey();
            aesKeyBytes = aesKey.getEncoded();

            byte[] iv = new byte[GCM_IV_LENGTH];
            new SecureRandom().nextBytes(iv);

            Cipher aesCipher = Cipher.getInstance(AES_ALGORITHM);
            aesCipher.init(Cipher.ENCRYPT_MODE, aesKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            byte[] encryptedContract = aesCipher.doFinal(contractBytes);
            saveBytes(encryptedContract, dataDir + "/" + ENCRYPTED_CONTRACT);
            saveBytes(iv, dataDir + "/" + IV_FILE);

            PublicKey influencerPublicKey = KeyManager.loadPublicKey(dataDir + "/" + INFLUENCER_PUBLIC);
            Cipher rsaCipher = Cipher.getInstance(RSA_ALGORITHM);
            rsaCipher.init(Cipher.ENCRYPT_MODE, influencerPublicKey);
            byte[] encryptedAesKey = rsaCipher.doFinal(aesKeyBytes);
            saveBytes(encryptedAesKey, dataDir + "/" + ENCRYPTED_AES_KEY);

            MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM);
            byte[] contractHash = md.digest(contractBytes);
            saveBytes(contractHash, dataDir + "/" + CONTRACT_HASH);

            PrivateKey brandPrivateKey = KeyManager.loadPrivateKey(dataDir + "/" + BRAND_PRIVATE);
            Signature signer = Signature.getInstance(SIGN_ALGORITHM);
            signer.initSign(brandPrivateKey);
            signer.update(contractBytes);
            byte[] brandSignature = signer.sign();
            saveBytes(brandSignature, dataDir + "/" + BRAND_SIGNATURE);

            return new EnvelopeResult(true, "전자봉투 생성 완료",
                    dataDir + "/" + CONTRACT_FILE,
                    dataDir + "/" + ENCRYPTED_CONTRACT,
                    dataDir + "/" + IV_FILE,
                    dataDir + "/" + ENCRYPTED_AES_KEY,
                    dataDir + "/" + CONTRACT_HASH,
                    dataDir + "/" + BRAND_SIGNATURE);

        } catch (GeneralSecurityException | IOException e) {
            LOG.log(Level.SEVERE, "전자봉투 생성 실패", e);
            return EnvelopeResult.failure("전자봉투 생성 중 오류가 발생했습니다.");
        } finally {
            if (aesKeyBytes != null) {
                Arrays.fill(aesKeyBytes, (byte) 0);
            }
            if (contractBytes != null) {
                Arrays.fill(contractBytes, (byte) 0);
            }
        }
    }

    private static void saveBytes(byte[] data, String filePath) throws IOException {
        Files.write(Paths.get(filePath), data);
    }
}
