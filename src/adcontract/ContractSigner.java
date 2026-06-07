package adcontract;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;

public class ContractSigner {

    private static final String SIGN_ALGORITHM = "SHA256withRSA";

    private final String dataDir;

    public ContractSigner(String dataDir) {
        this.dataDir = dataDir;
    }

    public void sign(byte[] contractBytes) throws Exception {
        if (contractBytes == null || contractBytes.length == 0) {
            throw new IllegalArgumentException("서명 대상 계약서 byte[]가 비어 있습니다.");
        }

        PrivateKey privateKey = loadPrivateKey("influencer_private.key");

        Signature sig = Signature.getInstance(SIGN_ALGORITHM);
        sig.initSign(privateKey);
        sig.update(contractBytes);
        byte[] signatureBytes = sig.sign();

        writeFile("influencer_signature.bin", signatureBytes);
    }

    private PrivateKey loadPrivateKey(String fileName) throws Exception {
        byte[] keyBytes = Files.readAllBytes(Paths.get(dataDir, fileName));
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        return kf.generatePrivate(spec);
    }

    private void writeFile(String fileName, byte[] data) throws IOException {
        Files.write(Paths.get(dataDir, fileName), data);
    }
}