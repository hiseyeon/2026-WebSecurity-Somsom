package adcontract;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Arrays;

public class EnvelopeVerifier {

    private static final String AES_ALGORITHM = "AES/GCM/NoPadding";
    private static final String RSA_ALGORITHM = "RSA/ECB/OAEPWithSHA-256AndMGF1Padding";
    private static final String HASH_ALGORITHM = "SHA-256";
    private static final String SIGN_ALGORITHM = "SHA256withRSA";
    private static final int GCM_TAG_LENGTH_BITS = 128;
    private static final int IV_LENGTH_BYTES = 12;

    private final String dataDir;

    public EnvelopeVerifier(String dataDir) {
        this.dataDir = dataDir;
    }

	public VerifyResult verify() {
        VerifyResult result = new VerifyResult();

        byte[] contractBytes;

        SecretKey aesKey;
        try {
            byte[] encryptedAesKey = readFile("encrypted_aes_key.bin");
            PrivateKey influencerPrivateKey = loadPrivateKey("influencer_private.key");
            aesKey = decryptAesKey(encryptedAesKey, influencerPrivateKey);
            result.stepAesKey = true;
        } catch (Exception e) {
            result.stepAesKey = false;
            result.failReason = "AES 키 복호화 실패: " + e.getMessage();
            return result;
        }

        try {
            byte[] iv = readFile("iv.bin");
            byte[] encryptedContract = readFile("encrypted_contract.bin");
            contractBytes = decryptContract(encryptedContract, aesKey, iv);
            result.stepDecrypt = true;
            result.decryptedText = new String(contractBytes, "UTF-8");
        } catch (Exception e) {
            result.stepDecrypt = false;
            result.failReason = "계약서 복호화 실패: " + e.getMessage();
            return result;
        }

        try {
            byte[] recomputedHash = computeHash(contractBytes);
            byte[] storedHash = readFile("contract_hash.bin");
            result.stepHash = Arrays.equals(recomputedHash, storedHash);

            if (!result.stepHash) {
                result.failReason = "해시값 불일치 — 계약서가 변조되었습니다.";
                return result;
            }
        } catch (Exception e) {
            result.stepHash = false;
            result.failReason = "해시 검증 중 오류: " + e.getMessage();
            return result;
        }

        try {
            byte[] brandSignature = readFile("brand_signature.bin");
            PublicKey brandPublicKey = loadPublicKey("brand_public.key");
            result.stepBrandSig = verifySignature(contractBytes, brandSignature, brandPublicKey);

            if (!result.stepBrandSig) {
                result.failReason = "브랜드 서명 검증 실패 — 위조된 계약서이거나 서명이 잘못되었습니다.";
            }
        } catch (Exception e) {
            result.stepBrandSig = false;
            result.failReason = "브랜드 서명 검증 중 오류: " + e.getMessage();
        }

        result.contractBytes = contractBytes;

        return result;
    }

    private byte[] readFile(String fileName) throws IOException {
        return Files.readAllBytes(Paths.get(dataDir, fileName));
    }

    private PrivateKey loadPrivateKey(String fileName) throws Exception {
        byte[] keyBytes = readFile(fileName);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        return kf.generatePrivate(spec);
    }

    private PublicKey loadPublicKey(String fileName) throws Exception {
        byte[] keyBytes = readFile(fileName);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        return kf.generatePublic(spec);
    }

    private SecretKey decryptAesKey(byte[] encryptedAesKey, PrivateKey privateKey) throws Exception {
        Cipher cipher = Cipher.getInstance(RSA_ALGORITHM);
        cipher.init(Cipher.DECRYPT_MODE, privateKey);
        byte[] aesKeyBytes = cipher.doFinal(encryptedAesKey);
        return new SecretKeySpec(aesKeyBytes, "AES");
    }

    private byte[] decryptContract(byte[] encryptedData, SecretKey aesKey, byte[] iv) throws Exception {
        Cipher cipher = Cipher.getInstance(AES_ALGORITHM);
        GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv);
        cipher.init(Cipher.DECRYPT_MODE, aesKey, parameterSpec);
        return cipher.doFinal(encryptedData);
    }

    private byte[] computeHash(byte[] data) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM);
        return md.digest(data);
    }

    private boolean verifySignature(byte[] data, byte[] signature, PublicKey publicKey) throws Exception {
        Signature sig = Signature.getInstance(SIGN_ALGORITHM);
        sig.initVerify(publicKey);
        sig.update(data);
        return sig.verify(signature);
    }

    public static class VerifyResult {
        public boolean stepAesKey = false;
        public boolean stepDecrypt = false;
        public boolean stepHash = false;
        public boolean stepBrandSig = false;

        public String decryptedText = null;

        public byte[] contractBytes = null;

        public String failReason = null;

        public boolean isFullyVerified() {
            return stepAesKey && stepDecrypt && stepHash && stepBrandSig;
        }
    }
}