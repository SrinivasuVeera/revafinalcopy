public interface Encryption {
    String encrypt(String data, String Key);
    String decrypt(String toDecrypt, String key);
}