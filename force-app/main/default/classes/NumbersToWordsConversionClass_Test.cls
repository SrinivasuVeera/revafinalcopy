@istest
public class NumbersToWordsConversionClass_Test
{
    static testmethod void method()
    {
           NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
           cls.convert(1000);
    }
    static testmethod void method1()
    {
           NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
           cls.convert(10000);
    }
    static testmethod void method2()
    {
           NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
           cls.convert(100000);
    }
    static testmethod void method3()
    {
           NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
           cls.convert(1000000);
    }
    static testmethod void method4()
    {
           NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
           cls.convert(10000000);
    }
    static testmethod void method5()
    {
           NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
           cls.convert(100000000);
    }
}